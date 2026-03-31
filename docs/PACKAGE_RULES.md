# PACKAGE.JSON RULES

- frontend/package.json must exist
- Must include:
  "type": "module"

- Do not use PowerShell object mutation for JSON structure
- Always overwrite with valid JSON when fixing

This prevents runtime and parsing failures
