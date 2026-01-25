@echo off
setlocal EnableExtensions

REM Run guards using Windows PowerShell (available by default)
powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\guard_no_pm.ps1"
if errorlevel 1 exit /b 1

powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\scan_forbidden_tokens.ps1"
if errorlevel 1 exit /b 1

exit /b 0
