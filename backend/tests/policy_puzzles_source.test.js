const fs = require('fs');
const path = require('path');

test('Policy A: backend must not reference puzzles.json at runtime', () => {
  const serverPath = path.join(__dirname, '..', 'src', 'server.cjs');
  const raw = fs.readFileSync(serverPath, 'utf8');
  expect(raw.includes('puzzles.json')).toBe(false);
});

test('Policy A: index.json must exist (runtime source of truth)', () => {
  const indexPath = path.join(__dirname, '..', 'src', 'puzzles', 'index.json');
  expect(fs.existsSync(indexPath)).toBe(true);
});
