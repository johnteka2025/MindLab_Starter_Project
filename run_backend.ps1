$ErrorActionPreference = "Stop"
$running = Get-Job -Name mindlab-backend -ErrorAction SilentlyContinue | ? State -eq "Running"
if ($running) { Write-Host "Backend already running."; return }

Start-Job -Name mindlab-backend -ScriptBlock {
  $prefix = "http://127.0.0.1:8085/"
  $listener = New-Object System.Net.HttpListener
  $listener.Prefixes.Add($prefix)
  try { $listener.Start() } catch { throw "HttpListener failed. Run `ensure_urlacl.ps1` as admin once." }

  function Set-Cors([System.Net.HttpListenerResponse]$res){
    $res.Headers["Access-Control-Allow-Origin"]  = "http://127.0.0.1:5177"
    $res.Headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    $res.Headers["Access-Control-Allow-Headers"] = "Content-Type"
  }

  try {
    while ($true) {
      $ctx = $listener.GetContext()
      $req = $ctx.Request
      $res = $ctx.Response

      if ($req.HttpMethod -eq "OPTIONS") {
        Set-Cors $res; $res.StatusCode = 204; $res.ContentLength64 = 0; $res.OutputStream.Close(); continue
      }

      if ($req.HttpMethod -eq "GET" -and $req.RawUrl -eq "/health") {
        Set-Cors $res
        $bytes = [Text.Encoding]::UTF8.GetBytes('{"ok":true}')
        $res.StatusCode = 200; $res.ContentType = "application/json"; $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes,0,$bytes.Length); $res.OutputStream.Close()
      } else {
        Set-Cors $res
        $html = "<html><body><h1>Backend</h1><p>Try /health</p></body></html>"
        $bytes = [Text.Encoding]::UTF8.GetBytes($html)
        $res.StatusCode = 200; $res.ContentType = "text/html; charset=utf-8"; $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes,0,$bytes.Length); $res.OutputStream.Close()
      }
    }
  } finally { $listener.Stop() }
} | Out-Null

$deadline = (Get-Date).AddSeconds(5)
do { Start-Sleep -Milliseconds 200
     $listening = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | ? LocalPort -eq 8085
} until ($listening -or (Get-Date) -gt $deadline)
if ($listening) { Write-Host "Backend listening on :8085" } else { Write-Warning "Backend failed"; Receive-Job -Name mindlab-backend -Keep | Select-Object -Last 50 }
