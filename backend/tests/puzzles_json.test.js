const fs = require("fs");
const path = require("path");

test("puzzles.json is valid JSON and has at least 1 puzzle with id/question", () => {
  const puzzlesPath = path.resolve(__dirname, "..", "src", "puzzles.json");
  const raw = fs.readFileSync(puzzlesPath, "utf8").replace(/^\uFEFF/, "");
  const data = JSON.parse(raw);

  expect(Array.isArray(data)).toBe(true);
  expect(data.length).toBeGreaterThan(0);

  const first = data[0];
  expect(first).toHaveProperty("id");
  expect(first).toHaveProperty("question");
});
