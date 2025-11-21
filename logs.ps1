$jobs = Get-Job | ? Name -in "node-backend","node-frontend"
if (-not $jobs) { Write-Host "No jobs found."; return }
foreach ($j in $jobs) {
  Write-Host "`n=== $($j.Name) ($($j.State)) ==="
  Receive-Job -Id $j.Id -Keep | Select-Object -Last 50
}
