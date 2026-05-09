"use strict";

const fs = require("fs");
const path = require("path");
const { loadSeedPuzzleContent, stripUtf8Bom } = require("./production-content-loader.cjs");

const DEFAULT_MANIFEST_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "content",
  "seed-puzzles",
  "manifest.json"
);

const DEFAULT_SEED_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "content",
  "seed-puzzles",
  "mindlab-seed-puzzles.v1.json"
);

const REQUIRED_PUZZLE_FIELDS = Object.freeze([
  "id",
  "ageCategory",
  "title",
  "prompt",
  "choices",
  "answer",
  "explanation"
]);

function readJsonFileBomSafe(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`MISSING_CONTENT_FILE :: ${filePath}`);
  }

  const raw = fs.readFileSync(filePath, "utf8");
  return JSON.parse(stripUtf8Bom(raw));
}

function validateManifest(manifest, seedData) {
  if (!manifest || typeof manifest !== "object" || Array.isArray(manifest)) {
    throw new Error("INVALID_MANIFEST_SHAPE");
  }

  if (manifest.expectedPuzzleCount !== seedData.puzzles.length) {
    throw new Error(`MANIFEST_EXPECTED_COUNT_MISMATCH :: expected=${manifest.expectedPuzzleCount} actual=${seedData.puzzles.length}`);
  }

  return true;
}

function validatePuzzleSchema(puzzle) {
  for (const field of REQUIRED_PUZZLE_FIELDS) {
    if (!(field in puzzle)) {
      throw new Error(`PUZZLE_REQUIRED_FIELD_MISSING :: ${field} :: ${puzzle.id || "UNKNOWN_ID"}`);
    }
  }

  if (!Array.isArray(puzzle.choices) || puzzle.choices.length < 2) {
    throw new Error(`PUZZLE_CHOICES_INVALID :: ${puzzle.id}`);
  }

  if (!puzzle.choices.includes(puzzle.answer)) {
    throw new Error(`PUZZLE_ANSWER_NOT_IN_CHOICES :: ${puzzle.id}`);
  }

  return true;
}

function validateDuplicatePuzzleIds(puzzles) {
  const seen = new Set();

  for (const puzzle of puzzles) {
    if (seen.has(puzzle.id)) {
      throw new Error(`DUPLICATE_PUZZLE_ID :: ${puzzle.id}`);
    }

    seen.add(puzzle.id);
  }

  return true;
}

function groupPuzzlesByAgeCategory(puzzles) {
  return puzzles.reduce((groups, puzzle) => {
    const category = puzzle.ageCategory || "uncategorized";
    if (!groups[category]) {
      groups[category] = [];
    }

    groups[category].push(puzzle);
    return groups;
  }, {});
}

function validateAgeCategoryGroups(groups) {
  const categories = Object.keys(groups);

  if (categories.length === 0) {
    throw new Error("NO_AGE_CATEGORY_GROUPS_FOUND");
  }

  for (const category of categories) {
    if (!Array.isArray(groups[category]) || groups[category].length === 0) {
      throw new Error(`EMPTY_AGE_CATEGORY_GROUP :: ${category}`);
    }
  }

  return true;
}

function buildContentRegistry(options = {}) {
  const seedPath = options.seedPath || DEFAULT_SEED_PATH;
  const manifestPath = options.manifestPath || DEFAULT_MANIFEST_PATH;
  const seedData = loadSeedPuzzleContent(seedPath);
  const manifest = readJsonFileBomSafe(manifestPath);
  const puzzles = seedData.puzzles;

  validateManifest(manifest, seedData);
  validateDuplicatePuzzleIds(puzzles);

  for (const puzzle of puzzles) {
    validatePuzzleSchema(puzzle);
  }

  const puzzlesByAgeCategory = groupPuzzlesByAgeCategory(puzzles);
  validateAgeCategoryGroups(puzzlesByAgeCategory);

  return Object.freeze({
    manifest,
    seedData,
    puzzles,
    puzzlesByAgeCategory,
    counts: Object.freeze({
      total: puzzles.length,
      byAgeCategory: Object.freeze(
        Object.fromEntries(
          Object.entries(puzzlesByAgeCategory).map(([category, items]) => [category, items.length])
        )
      )
    })
  });
}

module.exports = {
  DEFAULT_MANIFEST_PATH,
  DEFAULT_SEED_PATH,
  REQUIRED_PUZZLE_FIELDS,
  buildContentRegistry,
  groupPuzzlesByAgeCategory,
  readJsonFileBomSafe,
  validateAgeCategoryGroups,
  validateDuplicatePuzzleIds,
  validateManifest,
  validatePuzzleSchema
};