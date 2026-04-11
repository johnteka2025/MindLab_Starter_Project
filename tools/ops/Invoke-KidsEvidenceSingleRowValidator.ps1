param(
    [string]$RepoRoot = "C:\Projects\MindLab_Starter_Project",
    [string]$SingleRowPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\row_lock\current_focus_single_submission_row.csv",
    [string]$RulesPath = "C:\Projects\MindLab_Starter_Project\docs\planning\kids_certified\06_ux_qa\kids_pilot_evidence_invalid_value_rules.json",
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

function Test-InvalidToken {
    param([string]$Value,[string[]]$InvalidTokens)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $true }
    return ($InvalidTokens -contains $Value.Trim().ToLowerInvariant())
}

Set-Location $RepoRoot

$rules = Get-Content -Path $RulesPath -Raw | ConvertFrom-Json
$invalidTokens = @($rules.invalid_tokens | ForEach-Object { [string]$_ })
$invalidTokens = @($invalidTokens | ForEach-Object { $_.Trim().ToLowerInvariant() })
$statusFields = @($rules.status_fields_must_equal_complete | ForEach-Object { [string]$_ })
$rows = @(Import-Csv $SingleRowPath)
if ($rows.Count -ne 1) { throw "Expected exactly one row in $SingleRowPath" }
$row = $rows[0]

$rvMin = [int]$rules.minimum_lengths.RequiredValue
$esMin = [int]$rules.minimum_lengths.EvidenceSource
$enMin = [int]$rules.minimum_lengths.EvidenceNote

do {
    $requiredValue = Read-Host "Enter RequiredValue for [$($row.Field)]"
    $requiredLower = [string]$requiredValue
    $requiredLower = $requiredLower.Trim().ToLowerInvariant()
    $requiredOk = (
        -not (Test-InvalidToken -Value $requiredValue -InvalidTokens $invalidTokens) -and
        $requiredValue.Trim().Length -ge $rvMin -and
        $requiredValue -ne [string]$row.SourceValue -and
        (
            (@($statusFields) -notcontains [string]$row.Field) -or
            ($requiredValue -eq "COMPLETE")
        )
    )
} until ($requiredOk)

do {
    $evidenceSource = Read-Host "Enter EvidenceSource for [$($row.Field)]"
    $evidenceSourceOk = (
        -not (Test-InvalidToken -Value $evidenceSource -InvalidTokens $invalidTokens) -and
        $evidenceSource.Trim().Length -ge $esMin
    )
} until ($evidenceSourceOk)

do {
    $evidenceNote = Read-Host "Enter EvidenceNote for [$($row.Field)]"
    $evidenceNoteOk = (
        -not (Test-InvalidToken -Value $evidenceNote -InvalidTokens $invalidTokens) -and
        $evidenceNote.Trim().Length -ge $enMin
    )
} until ($evidenceNoteOk)

$row.RequiredValue  = $requiredValue
$row.EvidenceSource = $evidenceSource
$row.EvidenceNote   = $evidenceNote
$row.EntryState     = "READY"

Write-CsvUtf8NoBom -Path $SingleRowPath -Rows @($row)

$reportRows = @(
    [pscustomobject]@{
        CertifiedID        = [string]$row.CertifiedID
        Field              = [string]$row.Field
        SourceValue        = [string]$row.SourceValue
        RequiredValue      = [string]$row.RequiredValue
        EvidenceSource     = [string]$row.EvidenceSource
        EvidenceNote       = [string]$row.EvidenceNote
        RequiredValueValid = $true
        EvidenceSourceValid= $true
        EvidenceNoteValid  = $true
        ValidationState    = "PASS"
    }
)

Write-CsvUtf8NoBom -Path $ValidationReport -Rows $reportRows
Write-Host ("TARGET_FIELD:{0}" -f [string]$row.Field) -ForegroundColor Yellow
Write-Host "OUTCOME:VALIDATED_SINGLE_ROW_CAPTURED" -ForegroundColor Green