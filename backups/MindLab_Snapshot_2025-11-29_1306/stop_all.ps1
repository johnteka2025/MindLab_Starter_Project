$jobs = "node-backend","node-frontend"
foreach ($j in $jobs) {
  $job = Get-Job -Name $j -ErrorAction SilentlyContinue
  if ($job) { Stop-Job -Name $j; Remove-Job -Name $j }
}
