import { existsSync } from "node:fs";
import { join } from "node:path";

const root = process.cwd();

const required = [
  "package.json",
  "backend/package.json",
  "frontend/package.json",
  "tools"
];

const missing = required.filter((item) => !existsSync(join(root, item)));

if (missing.length > 0) {
  console.error("[FAIL] Root validation missing paths:");
  for (const item of missing) console.error(`- ${item}`);
  process.exit(1);
}

console.log("[PASS] Root validation passed");
