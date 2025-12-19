const fs = require("fs");
const p = process.argv[2];
const s = fs.readFileSync(p, "utf8");
JSON.parse(s);
console.log("OK: puzzles.json parses as JSON");