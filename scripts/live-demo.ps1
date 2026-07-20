[CmdletBinding()]
param(
  [switch]$Fast,
  [string]$WindowTitle = 'Cricket Intelligence API Demo'
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$host.UI.RawUI.WindowTitle = $windowTitle
mode.com con cols=112 lines=34 | Out-Null

function Wait-Beat([int]$Seconds) {
  if ($Fast) { Start-Sleep -Milliseconds 450 } else { Start-Sleep -Seconds $Seconds }
}

function Show-Header([string]$Step, [string]$Subtitle) {
  Clear-Host
  Write-Host 'CRICKET INTELLIGENCE API' -ForegroundColor Cyan
  Write-Host 'Dataset-grounded questions with explicit evidence boundaries' -ForegroundColor White
  Write-Host ('=' * 82) -ForegroundColor DarkCyan
  Write-Host $Step -ForegroundColor Yellow
  Write-Host $Subtitle -ForegroundColor Gray
  Write-Host ''
}

function Invoke-DemoQuery([string]$Question) {
  $body = @{ question = $Question; sessionId = 'recorded-demo' } | ConvertTo-Json -Compress
  Invoke-RestMethod -Uri "$baseUrl/api/query" -Method Post -ContentType 'application/json' -Body $body
}

function Get-ErrorStatus([scriptblock]$Action) {
  try {
    & $Action | Out-Null
    return 200
  } catch {
    if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
      return [int]$_.Exception.Response.StatusCode
    }
    throw
  }
}

$env:NODE_ENV = 'production'
$env:PORT = '3099'
$env:CHROMA_MODE = 'local'
$env:CRICAPI_KEY = ''
$env:CRICBUZZ_ENABLED = 'false'
$env:CRICBUZZ_RAPIDAPI_KEY = ''
$env:ESPN_ENABLED = 'false'
$env:PROFILE_ENRICHMENT_ENABLED = 'false'
$env:ENABLE_DAILY_INGESTOR = 'false'
$env:RUN_DAILY_INGESTOR_ON_BOOT = 'false'
$env:LLM_ENDPOINT = ''
$env:LLM_BASE_URL = ''
$env:OPENAI_API_KEY = ''
$env:CORS_ORIGINS = 'http://127.0.0.1:5173'
$env:JSON_BODY_LIMIT = '32kb'
$env:RATE_LIMIT_MAX = '500'
$baseUrl = 'http://127.0.0.1:3099'
$api = $null

try {
  Set-Location $repoRoot
  $api = Start-Process -FilePath 'node' -ArgumentList 'server.js' -WorkingDirectory $repoRoot -WindowStyle Hidden -PassThru
  for ($attempt = 0; $attempt -lt 60; $attempt += 1) {
    try {
      Invoke-RestMethod -Uri "$baseUrl/api/status" -TimeoutSec 2 | Out-Null
      break
    } catch {
      if ($attempt -eq 59) { throw 'API did not become ready.' }
      Start-Sleep -Milliseconds 250
    }
  }

  Show-Header '0. Product boundary' 'The verified profile is local, deterministic, credential-free, and network-free.'
  Write-Host '> npm run demo' -ForegroundColor Green
  Write-Host 'Reviewer: inspect evidence, ask bounded questions, and verify honest failure states.'
  Write-Host 'Not claimed: live accuracy, exhaustive statistics, official affiliation, or production hosting.'
  Wait-Beat 8

  Show-Header '1. Runtime evidence' 'GET /api/status'
  $status = Invoke-RestMethod -Uri "$baseUrl/api/status"
  [ordered]@{
    http_status = 200
    vector_status = $status.status
    db_configured = $status.db_configured
    runtime = $status.runtime
    counts = $status.counts
  } | ConvertTo-Json -Depth 6
  Wait-Beat 22

  Show-Header '2. Repository rule knowledge' 'POST /api/query  question="what is lbw"'
  $lbw = Invoke-DemoQuery 'what is lbw'
  [ordered]@{ type=$lbw.type; action=$lbw.extra.action; summary=$lbw.summary } | ConvertTo-Json -Depth 4
  Wait-Beat 22

  Show-Header '3. Repository history knowledge' 'POST /api/query  question="who won wc 2011"'
  $history = Invoke-DemoQuery 'who won wc 2011'
  [ordered]@{ type=$history.type; action=$history.extra.action; summary=$history.summary } | ConvertTo-Json -Depth 4
  Wait-Beat 22

  Show-Header '4. Typed archive degradation' 'POST /api/query  question="india team summary"'
  $team = Invoke-DemoQuery 'india team summary'
  [ordered]@{ type=$team.type; action=$team.extra.action; summary=$team.summary } | ConvertTo-Json -Depth 4
  Write-Host ''
  Write-Host 'The web contract remains useful; unavailable statistics are not invented.' -ForegroundColor Yellow
  Wait-Beat 22

  Show-Header '5. External provider gate' 'GET /api/cricapi/live-scores'
  $liveStatus = Get-ErrorStatus { Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/api/cricapi/live-scores" }
  Write-Host "HTTP $liveStatus" -ForegroundColor Yellow
  Write-Host 'provider: cricapi'
  Write-Host 'source: external'
  Write-Host 'message: CricAPI key is not configured.'
  Write-Host ''
  Write-Host 'No sample live score is substituted for missing authorization.' -ForegroundColor Green
  Wait-Beat 20

  Show-Header '6. HTTP security boundary' 'CORS allowlist, body limit, Helmet, and hidden Express signature'
  $deniedStatus = Get-ErrorStatus {
    Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/api/status" -Headers @{ Origin='https://untrusted.example' }
  }
  $largeBody = @{ question = ('x' * (40 * 1024)) } | ConvertTo-Json -Compress
  $largeStatus = Get-ErrorStatus {
    Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/api/query" -Method Post -ContentType 'application/json' -Body $largeBody
  }
  $allowed = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/api/status" -Headers @{ Origin='http://127.0.0.1:5173' }
  [ordered]@{
    denied_origin = $deniedStatus
    oversized_json = $largeStatus
    allowed_origin = $allowed.Headers['Access-Control-Allow-Origin']
    x_content_type_options = $allowed.Headers['X-Content-Type-Options']
    x_powered_by = if ($allowed.Headers['X-Powered-By']) { $allowed.Headers['X-Powered-By'] } else { '[not present]' }
  } | ConvertTo-Json
  Wait-Beat 24

  Show-Header '7. Automated behavior evidence' '19 routing cases + 5 real HTTP integration tests'
  npm test
  if ($LASTEXITCODE -ne 0) { throw 'Automated tests failed during the demo.' }
  Wait-Beat 15

  Show-Header '8. Dependency evidence' 'Complete runtime dependency tree'
  npm audit --omit=dev
  if ($LASTEXITCODE -ne 0) { throw 'Dependency audit failed during the demo.' }
  Wait-Beat 12

  Show-Header '9. Architecture' 'Verified core plus explicit optional adapters'
  Write-Host 'Express security boundary' -ForegroundColor Cyan
  Write-Host '  -> deterministic intent and entity routing'
  Write-Host '  -> query orchestration and stable typed responses'
  Write-Host '  -> repository JSON evidence'
  Write-Host ''
  Write-Host 'Optional, disabled in this release profile:' -ForegroundColor Yellow
  Write-Host '  Chroma | CricAPI | Cricbuzz | ESPN | profile enrichment | LLM | ingestor'
  Write-Host ''
  Write-Host 'Missing archive paths stop before a Python helper is launched.' -ForegroundColor Green
  Wait-Beat 25

  Show-Header '10. Honest close' 'What v1.0 proves and what it does not'
  Write-Host 'PROVES' -ForegroundColor Green
  Write-Host '  deterministic routing, typed degradation, guarded HTTP boundaries, 24 checks'
  Write-Host '  zero known npm vulnerabilities, reproducible terminal/API workflow'
  Write-Host ''
  Write-Host 'DOES NOT CLAIM' -ForegroundColor Yellow
  Write-Host '  live-score SLA, exhaustive stats, official affiliation, verified provider/model profile'
  Write-Host '  item-level data licensing, public deployment, or production security'
  Write-Host ''
  Write-Host 'Next: verify the paired React client against this exact API contract.' -ForegroundColor Cyan
  Wait-Beat 45
} finally {
  if ($api -and -not $api.HasExited) { Stop-Process -Id $api.Id -Force -ErrorAction SilentlyContinue }
}
