Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

function Strip-Strings([string]$s){
  if([string]::IsNullOrEmpty($s)){ return $s }
  # remove single-quoted and double-quoted string literals (best-effort)
  $s = [regex]::Replace($s,"'[^']*'","''")
  $s = [regex]::Replace($s,'"(?:[^"\\]|\\.)*"','""')
  return $s
}

try{
  $REPO="C:\Projects\MindLab_Starter_Project"
  $self="C:\Projects\MindLab_Starter_Project\tools\BAN_PID_SCAN.ps1"

  $files = Get-ChildItem "$REPO\tools","$REPO\backend" -Recurse -File -Include *.ps1,*.psm1 -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -ne $self }

  if(-not $files){ throw "STOP: no ps files found" }

  $hitsOut = New-Object System.Collections.Generic.List[string]

  foreach($f in $files){
    $lines = Get-Content $f.FullName -ErrorAction SilentlyContinue
    if(-not $lines){ continue }

    for($i=0;$i -lt $lines.Count;$i++){
      $line=$lines[$i]

      # ignore pure comment lines
      if($line -match '^\s*#'){ continue }

      $scan = Strip-Strings $line

      # detect actual token usage (not inside quotes)
      if($scan -match '(?i)\$pid\b'){
        $hitsOut.Add(("{0}:{1} {2}" -f $f.FullName,($i+1),$line))
      }
    }
  }

  if($hitsOut.Count -gt 0){
    $hitsOut | Out-Host
    throw 'STOP: banned token found ($pid). Replace with $backendPid or $puzzleId.'
  }

  Write-Host 'OK: no banned token ($pid) found (comments + strings ignored)' -ForegroundColor Green
}
catch{
  Write-Host $_ -ForegroundColor Red
}
finally{
  Read-Host "Press ENTER to exit"
}

