const path = require("path");

test("progressRoutes module loads and exports a function", () => {
  const modPath = path.resolve(__dirname, "..", "src", "progressRoutes.cjs");
  const mod = require(modPath);
  expect(typeof mod).toBe("function");
});
