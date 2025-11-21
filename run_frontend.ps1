$ErrorActionPreference = "Stop"
$running = Get-Job -Name mindlab-frontend -ErrorAction SilentlyContinue | ? State -eq "Running"
if ($running) { Write-Host "Frontend already running."; return }

Start-Job -Name mindlab-frontend -ScriptBlock {
  $prefix = "http://127.0.0.1:5177/"
  $listener = New-Object System.Net.HttpListener
  $listener.Prefixes.Add($prefix)
  try { $listener.Start() } catch { throw "HttpListener failed. Run `ensure_urlacl.ps1` as admin once." }

  $html = @"
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Frontend</title></head>
  <body>
    <h1>Frontend</h1>
    <pre id="out">loading...</pre>
    <script>
      fetch('http://127.0.0.1:8085/health')
        .then(r => r.json())
        .then(j => document.getElementById('out').textContent = JSON.stringify(j,null,2))
        .catch(e => document.getElementById('out').textContent = 'fetch failed: ' + e);
    </script>
  </body>
</html>
"@

  try {
    while ($true) {
      $ctx = $listener.GetContext()
      $res = $ctx.Response
      $bytes = [Text.Encoding]::UTF8.GetBytes($html)
      $res.StatusCode = 200; $res.ContentType = "text/html; charset=utf-8"; $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes,0,$bytes.Length); $res.OutputStream.Close()
    }
  } finally { $listener.Stop() }
} | Out-Null

$deadline = (Get-Date).AddSeconds(5)
do { Start-Sleep -Milliseconds 200
     $listening = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | ? LocalPort -eq 5177
} until ($listening -or (Get-Date) -gt $deadline)
if ($listening) { Write-Host "Frontend listening on :5177" } else { Write-Warning "Frontend failed"; Receive-Job -Name mindlab-frontend -Keep | Select-Object -Last 50 }
