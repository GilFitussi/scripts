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
  migrationDir: path.resolve(__dirname, "migrations"),
  dataFile: path.resolve(__dirname, "x_data.json")
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

async function insertMultipleDocuments(db, collectionName, docs) {
  for (const doc of docs) {
    await insertDocument(db, collectionName, doc);
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

  const xData = JSON.parse(fs.readFileSync(config.dataFile, "utf-8"));
  await insertMultipleDocuments(db, "x", xData);

  await insertDocument(db, "y", { name: "Y1", createdAt: new Date(TAG) });
  await updateDocuments(db, "z", { status: "old" }, { $set: { status: "new", updatedAt: new Date(TAG) } });

  await client.close();
  logger.info("Migration complete.");
}

runMigration().catch((err) => {
  logger.error("Migration failed: " + err);
  process.exit(1);
});
