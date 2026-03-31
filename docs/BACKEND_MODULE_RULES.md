# BACKEND MODULE RULES

- backend MUST use CommonJS (require)
- DO NOT set "type": "module" in backend/package.json
- Converting backend to ESM requires full rewrite of server.js

Violation will break backend startup
