"use strict";

const assert = require("assert");
const {
  REQUIRED_PUZZLE_FIELDS,
  buildContentRegistry
} = require("./production-content-registry.cjs");

function runContentRegistrySmoke() {
  const registry = buildContentRegistry();

  assert.strictEqual(registry.counts.total, 9);
  assert.strictEqual(registry.seedData.puzzles.length, 9);
  assert.strictEqual(registry.manifest.expectedPuzzleCount, 9);
  assert.ok(Object.keys(registry.puzzlesByAgeCategory).length > 0);

  for (const puzzle of registry.puzzles) {
    for (const field of REQUIRED_PUZZLE_FIELDS) {
      assert.ok(field in puzzle, `MISSING_REQUIRED_FIELD_${field}_${puzzle.id}`);
    }

    assert.ok(Array.isArray(puzzle.choices));
    assert.ok(puzzle.choices.includes(puzzle.answer));
  }

  const groupedTotal = Object.values(registry.counts.byAgeCategory).reduce((sum, count) => sum + count, 0);
  assert.strictEqual(groupedTotal, 9);

  console.log("PASS: PRODUCTION_CONTENT_REGISTRY_SMOKE_PASS");
}

try {
  runContentRegistrySmoke();
} catch (error) {
  console.error("FAIL: PRODUCTION_CONTENT_REGISTRY_SMOKE_FAILED");
  console.error(error);
  process.exitCode = 1;
}

module.exports = {
  runContentRegistrySmoke
};