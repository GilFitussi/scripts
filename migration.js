// logger.js
const { createLogger, format, transports } = require("winston");

const logger = createLogger({
  level: "info",
  format: format.combine(
    format.timestamp({ format: "YYYY-MM-DD HH:mm:ss" }),
    format.printf(({ timestamp, level, message }) => {
      return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
    })
  ),
  transports: [
    new transports.Console(),
    new transports.File({ filename: "migration.log" })
  ]
});

module.exports = logger;

// config.js
require("dotenv").config();
const path = require("path");

const config = {
  mongoUri: process.env.MONGO_URI,
  dbName: "test_db",
  dryRun: process.env.DRY_RUN === "true",
  migrationDir: path.resolve(__dirname, "migrations")
};

module.exports = config;

// migration.js
const fs = require("fs");
const path = require("path");
const { MongoClient } = require("mongodb");
const config = require("./config");
const logger = require("./logger");

const TAG = new Date().toISOString().replace(/[:.]/g, "_");
const MIGRATION_FILE = path.join(config.migrationDir, `migration_${TAG}.json`);

const migrationLog = {
  tag: TAG,
  createdAt: new Date().toISOString(),
  actions: []
};

async function connectToDB() {
  const client = new MongoClient(config.mongoUri);
  await client.connect();
  return { client, db: client.db(config.dbName) };
}

async function logAction(entry) {
  migrationLog.actions.push(entry);
  fs.writeFileSync(MIGRATION_FILE, JSON.stringify(migrationLog, null, 2));
}

async function insertDocument(db, collectionName, doc) {
  if (config.dryRun) {
    logger.info(`[DRY RUN] Would insert into '${collectionName}': ${JSON.stringify(doc)}`);
    await logAction({ collection: collectionName, action: "insert", status: "dryRun", document: doc });
  } else {
    try {
      const res = await db.collection(collectionName).insertOne(doc);
      logger.info(`Inserted into '${collectionName}'`);
      await logAction({ collection: collectionName, action: "insert", status: "success", _id: res.insertedId, document: doc });
    } catch (err) {
      logger.error(`Insert failed in '${collectionName}': ${err}`);
      await logAction({ collection: collectionName, action: "insert", status: "error", error: err.toString(), document: doc });
    }
  }
}

async function updateDocuments(db, collectionName, filter, update) {
  if (config.dryRun) {
    const docs = await db.collection(collectionName).find(filter).toArray();
    logger.info(`[DRY RUN] Would update ${docs.length} docs in '${collectionName}'`);
    for (const doc of docs) {
      await logAction({ collection: collectionName, action: "update", status: "dryRun", _id: doc._id, previous: doc, update });
    }
  } else {
    const docs = await db.collection(collectionName).find(filter).toArray();
    for (const doc of docs) {
      try {
        await db.collection(collectionName).updateOne({ _id: doc._id }, update);
        logger.info(`Updated document ${doc._id} in '${collectionName}'`);
        await logAction({ collection: collectionName, action: "update", status: "success", _id: doc._id, previous: doc, update });
      } catch (err) {
        logger.error(`Update failed for _id=${doc._id} in '${collectionName}': ${err}`);
        await logAction({ collection: collectionName, action: "update", status: "error", _id: doc._id, error: err.toString(), update });
      }
    }
  }
}

async function runMigration() {
  fs.mkdirSync(config.migrationDir, { recursive: true });
  const { client, db } = await connectToDB();
  logger.info(`Starting migration (DRY_RUN=${config.dryRun})`);
  logger.info(`Tag: ${TAG}`);

  await insertDocument(db, "x", { name: "X1", createdAt: new Date(TAG) });
  await insertDocument(db, "y", { name: "Y1", createdAt: new Date(TAG) });
  await updateDocuments(db, "z", { status: "old" }, { $set: { status: "new", updatedAt: new Date(TAG) } });

  await client.close();
  logger.info("Migration complete.");
}

runMigration().catch((err) => {
  logger.error("Migration failed: " + err);
  process.exit(1);
});

// undo.js
const fsUndo = require("fs");
const pathUndo = require("path");
const { MongoClient: MongoClientUndo, ObjectId } = require("mongodb");
const configUndo = require("./config");
const loggerUndo = require("./logger");

const TAG_UNDO = process.argv[2];
const FILTER_ID = process.argv[3]; // Optional _id to restore only one doc

if (!TAG_UNDO) {
  console.error("Please provide a tag to undo. Usage: node undo.js <TAG> [optional _id]");
  process.exit(1);
}

const FILE_PATH = pathUndo.join(configUndo.migrationDir, `migration_${TAG_UNDO}.json`);
if (!fsUndo.existsSync(FILE_PATH)) {
  console.error(`Migration file not found: ${FILE_PATH}`);
  process.exit(1);
}

const migrationData = JSON.parse(fsUndo.readFileSync(FILE_PATH, "utf-8"));

async function connectToDBUndo() {
  const client = new MongoClientUndo(configUndo.mongoUri);
  await client.connect();
  return { client, db: client.db(configUndo.dbName) };
}

async function undoMigration() {
  const { client, db } = await connectToDBUndo();
  loggerUndo.info(`Starting undo for tag ${TAG_UNDO}${FILTER_ID ? ` (filtered by _id=${FILTER_ID})` : ""}`);

  const actions = FILTER_ID ? migrationData.actions.filter(a => String(a._id) === FILTER_ID) : migrationData.actions;

  for (const action of actions) {
    try {
      if (action.action === "insert" && action.status === "success") {
        await db.collection(action.collection).deleteOne({ _id: new ObjectId(action._id) });
        loggerUndo.info(`Deleted inserted doc _id=${action._id} from '${action.collection}'`);
      }
      if (action.action === "update" && action.status === "success" && action.previous) {
        await db.collection(action.collection).replaceOne({ _id: new ObjectId(action._id) }, action.previous);
        loggerUndo.info(`Restored doc _id=${action._id} in '${action.collection}'`);
      }
    } catch (err) {
      loggerUndo.error(`Undo failed for _id=${action._id} in '${action.collection}': ${err}`);
    }
  }

  await client.close();
  loggerUndo.info("Undo complete.");
}

undoMigration().catch(err => {
  loggerUndo.error("Undo script failed: " + err);
  process.exit(1);
});
