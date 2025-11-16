# Installer
$ErrorActionPreference = "Stop"

# Required hash
$REQUIRED_HASH = "bb30f0ac65d69ee8ec3fc22f1214f3c5cdf40b42c5a05c1b02da314bc9e4a0ad"

# Verify
if (-not $env:SPECFLOW_KEY) {
    Write-Host "Access denied" -ForegroundColor Red
    Write-Host "Set: `$env:SPECFLOW_KEY = `"****`"" -ForegroundColor Yellow
    exit 1
}

$inputBytes = [System.Text.Encoding]::UTF8.GetBytes($env:SPECFLOW_KEY)
$hashBytes = [System.Security.Cryptography.SHA256]::Create().ComputeHash($inputBytes)
$inputHash = [System.BitConverter]::ToString($hashBytes).Replace("-", "").ToLower()

if ($inputHash -ne $REQUIRED_HASH) {
    Write-Host "Invalid key" -ForegroundColor Red
    exit 1
}

# Config
$claudeConfigPaths = @(
    "$env:USERPROFILE\.claude",
    "$env:APPDATA\.claude",
    "$HOME\.claude"
)

$claudeConfigDir = $null
foreach ($path in $claudeConfigPaths) {
    if (Test-Path $path) {
        $claudeConfigDir = $path
        break
    }
}

if (-not $claudeConfigDir) {
    $claudeConfigDir = "$env:USERPROFILE\.claude"
}

$skillDir = Join-Path $claudeConfigDir "skills\specflow"

try {
    if (-not (Test-Path $skillDir)) {
        New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    }
} catch {
    Write-Host "Failed" -ForegroundColor Red
    exit 1
}

# Download
$skillUrl = "https://raw.githubusercontent.com/feizaiguai/gongju1/main/.claude/skills/specflow/SKILL.md"
$skillFile = Join-Path $skillDir "SKILL.md"

Write-Host "Installing..." -ForegroundColor Green

try {
    Invoke-WebRequest -Uri $skillUrl -OutFile $skillFile -UseBasicParsing
} catch {
    Write-Host "Failed" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $skillFile)) {
    Write-Host "Failed" -ForegroundColor Red
    exit 1
}

Write-Host "Done" -ForegroundColor Green
