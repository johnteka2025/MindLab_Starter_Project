"use strict";

const fs = require("fs");
const path = require("path");

const DEFAULT_SEED_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "content",
  "seed-puzzles",
  "mindlab-seed-puzzles.v1.json"
);

function stripUtf8Bom(raw) {
  if (typeof raw !== "string") {
    return raw;
  }

  return raw.charCodeAt(0) === 0xfeff ? raw.slice(1) : raw;
}

function readJsonFile(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`MISSING_SEED_CONTENT_FILE :: ${filePath}`);
  }

  const raw = fs.readFileSync(filePath, "utf8");
  return JSON.parse(stripUtf8Bom(raw));
}

function validateSeedPuzzleContent(seedData) {
  if (!seedData || !Array.isArray(seedData.puzzles)) {
    throw new Error("INVALID_SEED_CONTENT_SHAPE");
  }

  if (seedData.puzzles.length !== 9) {
    throw new Error(`INVALID_SEED_PUZZLE_COUNT :: ${seedData.puzzles.length}`);
  }

  const missingIds = seedData.puzzles.filter((puzzle) => !puzzle.id);
  if (missingIds.length > 0) {
    throw new Error(`INVALID_SEED_PUZZLE_MISSING_ID_COUNT :: ${missingIds.length}`);
  }

  return true;
}

function loadSeedPuzzleContent(seedPath = DEFAULT_SEED_PATH) {
  const seedData = readJsonFile(seedPath);
  validateSeedPuzzleContent(seedData);
  return seedData;
}

module.exports = {
  DEFAULT_SEED_PATH,
  loadSeedPuzzleContent,
  readJsonFile,
  stripUtf8Bom,
  validateSeedPuzzleContent
};
