# MindLab CI and Release Automation

## Files
- .github/workflows/mindlab-ci.yml
- tools/EXPORT_RELEASE_PACKAGE.ps1
- tools/CI_RELEASE_AUTOMATION_README.md

## Purpose
- Run RUN_ALL_GATES automatically on push and pull request
- Export release package from verified archived files
- Keep release/export workflow deterministic

## Manual Commands
powershell:
& "C:\Projects\MindLab_Starter_Project\tools\RUN_ALL_GATES.ps1"
& "C:\Projects\MindLab_Starter_Project\tools\EXPORT_RELEASE_PACKAGE.ps1"

## Critical Paths
- C:\Projects\MindLab_Starter_Project\.github\workflows\mindlab-ci.yml
- C:\Projects\MindLab_Starter_Project\tools\EXPORT_RELEASE_PACKAGE.ps1
- C:\Projects\MindLab_Starter_Project\tools\CI_RELEASE_AUTOMATION_README.md
- C:\Projects\MindLab_Starter_Project\tools\RUN_ALL_GATES.ps1

## Expected Outcome
- CI workflow exists
- Release export script exists
- Documentation exists
- Gates remain green
- Repo remains clean
