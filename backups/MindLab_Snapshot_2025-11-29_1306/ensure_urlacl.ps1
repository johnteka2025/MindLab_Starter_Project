$ErrorActionPreference = "Stop"
$needAdmin = -not ([bool](New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
if ($needAdmin) { Write-Warning "Run this script from an *Administrator* PowerShell."; return }
& netsh http add urlacl url=http://127.0.0.1:8085/ user=Everyone
& netsh http add urlacl url=http://127.0.0.1:5177/ user=Everyone
