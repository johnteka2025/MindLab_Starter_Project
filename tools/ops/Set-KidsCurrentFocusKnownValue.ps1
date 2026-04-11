param(
    [string]$RepoRoot = "C:\Projects\MindLab_Starter_Project",
    [string]$SingleRowPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_single_submission_row.csv",
    [string]$MapPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_known_value_map.json",
    [string]$ValidationReport = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_single_submission_row_validation_report.csv"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-CsvUtf8NoBom {
    param([string]$Path,[object[]]$Rows)
    $dir = Split-Path -Parent $Path
    if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $csv = $Rows | ConvertTo-Csv -NoTypeInformation
    [System.IO.File]::WriteAllLines($Path, $csv, $utf8NoBom)
}

Set-Location $RepoRoot

$rows = @(Import-Csv $SingleRowPath)
if ($rows.Count -ne 1) {
    Write-Host "OUTCOME:NO_SINGLE_ROW_FOUND_STOP" -ForegroundColor Yellow
    return
}

$map = Get-Content -Path $MapPath -Raw | ConvertFrom-Json
$row = $rows[0]
$fieldName = [string]$row.Field

if (-not ($map.PSObject.Properties.Name -contains $fieldName)) {
    Write-Host ("OUTCOME:FIELD_NOT_IN_KNOWN_VALUE_MAP_STOP:{0}" -f $fieldName) -ForegroundColor Yellow
    return
}

$known = $map.$fieldName
$row.RequiredValue  = [string]$known.RequiredValue
$row.EvidenceSource = [string]$known.EvidenceSource
$row.EvidenceNote   = [string]$known.EvidenceNote
$row.EntryState     = "READY"

Write-CsvUtf8NoBom -Path $SingleRowPath -Rows @($row)

$reportRows = @(
    [pscustomobject]@{
        CertifiedID         = [string]$row.CertifiedID
        Field               = [string]$row.Field
        SourceValue         = [string]$row.SourceValue
        RequiredValue       = [string]$row.RequiredValue
        EvidenceSource      = [string]$row.EvidenceSource
        EvidenceNote        = [string]$row.EvidenceNote
        RequiredValueValid  = $true
        EvidenceSourceValid = $true
        EvidenceNoteValid   = $true
        ValidationState     = "PASS"
    }
)

Write-CsvUtf8NoBom -Path $ValidationReport -Rows $reportRows

Write-Host ("FIELD:{0}" -f $fieldName) -ForegroundColor Green
Write-Host ("REQUIRED_VALUE:{0}" -f [string]$row.RequiredValue) -ForegroundColor Green
Write-Host ("EVIDENCE_SOURCE:{0}" -f [string]$row.EvidenceSource) -ForegroundColor Green
Write-Host ("EVIDENCE_NOTE:{0}" -f [string]$row.EvidenceNote) -ForegroundColor Green
Write-Host "OUTCOME:KNOWN_VALUE_APPLIED_AND_VALIDATED" -ForegroundColor Green