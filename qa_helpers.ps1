function Get-HttpStatus {
  param(
    [Parameter(Mandatory)][ValidateSet("GET","POST","PUT","PATCH","DELETE","OPTIONS","HEAD")] [string]$Method,
    [Parameter(Mandatory)][string]$Uri,
    [hashtable]$Headers = @{},
    [string]$ContentType = "application/json",
    [object]$Body = $null
  )

  # Build parameters dynamically so we only send a body when appropriate
  $args = @{
    Method       = $Method
    Uri          = $Uri
    Headers      = $Headers
    ErrorAction  = 'Stop'
    UseBasicParsing = $true
  }

  # Only attach body & content-type for methods that allow a body
  if ($Body -ne $null -and $Method -in @('POST','PUT','PATCH','DELETE')) {
    $args['Body']        = $Body
    $args['ContentType'] = $ContentType
  }

  try {
    $resp = Invoke-WebRequest @args
    return [int]$resp.StatusCode
  } catch {
    if ($_.Exception.Response) {
      return [int]$_.Exception.Response.StatusCode
    } else {
      throw  # network errors, DNS, etc. -> stop the phase
    }
  }
}

function Get-Json {
  param([Parameter(Mandatory)][string]$Uri, [hashtable]$Headers = @{})
  Invoke-RestMethod -Uri $Uri -Headers $Headers -ErrorAction Stop
}
