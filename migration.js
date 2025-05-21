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

const config = {
  mongoUri: process.env.MONGO_URI,
  dbName: "test_db",
  dryRun: process.env.DRY_RUN === "true",
};

module.exports = config;

// migration.js
const { MongoClient } = require("mongodb");
const config = require("./config");
const logger = require("./logger");

const TAG = new Date().toISOString().replace(/[:.]/g, "_");

async function connectToDB() {
  const client = new MongoClient(config.mongoUri);
  await client.connect();
  return { client, db: client.db(config.dbName) };
}

async function backupDocuments(db, collectionName, filter) {
  const docs = await db.collection(collectionName).find(filter).toArray();
  if (!docs.length) {
    logger.info(`ℹ️ No documents to back up in '${collectionName}'`);
    return;
  }
  const backupName = `_backup_${collectionName}_${TAG}`;
  await db.collection(backupName).insertMany(docs);
  logger.info(`📦 Backed up ${docs.length} docs from '${collectionName}' to '${backupName}'`);
}

async function insertDocument(db, collectionName, doc) {
  if (config.dryRun) {
    logger.info(`[DRY RUN] Would insert into '${collectionName}': ${JSON.stringify(doc)}`);
  } else {
    await db.collection(collectionName).insertOne(doc);
    logger.info(`✅ Inserted into '${collectionName}'`);
  }
}

async function updateDocuments(db, collectionName, filter, update) {
  if (config.dryRun) {
    const docs = await db.collection(collectionName).find(filter).toArray();
    logger.info(`[DRY RUN] Would update ${docs.length} docs in '${collectionName}'`);
  } else {
    await backupDocuments(db, collectionName, filter);
    const result = await db.collection(collectionName).updateMany(filter, update);
    logger.info(`✅ Updated ${result.modifiedCount} docs in '${collectionName}'`);
  }
}

async function runMigration() {
  const { client, db } = await connectToDB();
  logger.info(`🚀 Starting migration (DRY_RUN=${config.dryRun})`);
  logger.info(`🔖 Tag: ${TAG}`);

  await insertDocument(db, "x", { name: "X1", createdAt: new Date(TAG) });
  await insertDocument(db, "y", { name: "Y1", createdAt: new Date(TAG) });
  await updateDocuments(db, "z", { status: "old" }, { $set: { status: "new", updatedAt: new Date(TAG) } });

  await client.close();
  logger.info("🏁 Migration complete.");
}

runMigration().catch((err) => {
  logger.error("❌ Migration failed: " + err);
  process.exit(1);
});

// undo.js
const { MongoClient: MongoClientUndo } = require("mongodb");
const configUndo = require("./config");
const loggerUndo = require("./logger");

const TAG_UNDO = process.argv[2];
if (!TAG_UNDO) {
  console.error("❌ Please provide a tag to undo. Usage: node undo.js <TAG>");
  process.exit(1);
}

async function connectToDBUndo() {
  const client = new MongoClientUndo(configUndo.mongoUri);
  await client.connect();
  return { client, db: client.db(configUndo.dbName) };
}

async function undoMigration() {
  const { client, db } = await connectToDBUndo();

  loggerUndo.info(`🔁 Starting undo for tag ${TAG_UNDO}`);

  // delete from x and y by createdAt
  for (const col of ["x", "y"]) {
    const result = await db.collection(col).deleteMany({ createdAt: { $gte: new Date(TAG_UNDO.replace(/_/g, ":")) } });
    loggerUndo.info(`🗑️ Deleted ${result.deletedCount} docs from '${col}'`);
  }

  // restore z from backup
  const backupCollection = `_backup_z_${TAG_UNDO}`;
  const backupDocs = await db.collection(backupCollection).find().toArray();
  if (!backupDocs.length) {
    loggerUndo.warn(`⚠️ No backup found in '${backupCollection}'`);
  } else {
    const restoreOps = backupDocs.map(doc => ({
      updateOne: {
        filter: { _id: doc._id },
        update: { $set: doc },
        upsert: true
      }
    }));
    const result = await db.collection("z").bulkWrite(restoreOps);
    loggerUndo.info(`♻️ Restored ${result.modifiedCount + result.upsertedCount} docs to 'z' from '${backupCollection}'`);
  }

  await client.close();
  loggerUndo.info("✅ Undo complete.");
}

undoMigration().catch(err => {
  loggerUndo.error("❌ Undo failed: " + err);
  process.exit(1);
});
