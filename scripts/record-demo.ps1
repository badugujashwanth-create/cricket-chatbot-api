[CmdletBinding()]
param(
  [switch]$SmokeOnly,
  [string]$FfmpegPath = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$demoDir = Join-Path $repoRoot 'docs\demo'
$verificationDir = Join-Path $demoDir 'verification'
[IO.Directory]::CreateDirectory($verificationDir) | Out-Null
$windowTitle = 'Cricket Intelligence API Demo ' + [guid]::NewGuid().ToString('N')
$terminal = $null

function Stop-ProcessTree([int]$ProcessId) {
  $children = Get-CimInstance Win32_Process -Filter "ParentProcessId=$ProcessId" -ErrorAction SilentlyContinue
  foreach ($child in $children) { Stop-ProcessTree -ProcessId $child.ProcessId }
  Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
}

function Resolve-Ffmpeg([string]$RequestedPath) {
  if ($RequestedPath) { return (Resolve-Path $RequestedPath).Path }
  $installed = Get-Command ffmpeg -ErrorAction SilentlyContinue
  if ($installed) { return $installed.Source }

  $cache = Join-Path $env:TEMP 'workhub-ffmpeg-8.1.2'
  $cached = Get-ChildItem $cache -Recurse -Filter ffmpeg.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($cached) { return $cached.FullName }

  $zip = Get-ChildItem $cache -Filter 'ffmpeg-*-essentials_build.zip' -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $zip) { throw 'FFmpeg was not found. Install it or pass -FfmpegPath.' }
  $expanded = Join-Path $cache 'expanded'
  Expand-Archive -LiteralPath $zip.FullName -DestinationPath $expanded -Force
  $resolved = Get-ChildItem $expanded -Recurse -Filter ffmpeg.exe | Select-Object -First 1
  if (-not $resolved) { throw 'FFmpeg archive did not contain ffmpeg.exe.' }
  return $resolved.FullName
}

function New-Narration([string]$OutputPath) {
  Add-Type -AssemblyName System.Speech
  $paragraphs = (Get-Content -Raw -Encoding utf8 (Join-Path $demoDir 'NARRATION.md')) -split '(?:\r?\n){2,}' |
    Where-Object { $_ -and $_ -notmatch '^#' } |
    ForEach-Object { ($_ -replace '[`*_#]', '').Trim() }
  $builder = New-Object System.Speech.Synthesis.PromptBuilder
  foreach ($paragraph in $paragraphs) {
    $builder.AppendText($paragraph)
    $builder.AppendBreak([TimeSpan]::FromSeconds(2))
  }
  $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
  try {
    $voice.Rate = -1
    $voice.Volume = 90
    $voice.SetOutputToWaveFile($OutputPath)
    $voice.Speak($builder)
  } finally { $voice.Dispose() }
}

$ffmpeg = Resolve-Ffmpeg $FfmpegPath
$ffprobe = Join-Path (Split-Path -Parent $ffmpeg) 'ffprobe.exe'
if (-not (Test-Path $ffprobe)) { throw 'ffprobe.exe was not found beside FFmpeg.' }
$workDir = Join-Path $env:TEMP ('cricket-api-video-' + [guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($workDir) | Out-Null
$sourceVideo = Join-Path $workDir 'terminal-capture.mkv'
$captureSeconds = if ($SmokeOnly) { 18 } else { 262 }

try {
  $terminalArgs = @(
    'powershell.exe','-NoLogo','-NoProfile','-ExecutionPolicy','Bypass','-File',('"' + (Join-Path $PSScriptRoot 'live-demo.ps1') + '"'),
    '-WindowTitle',('"' + $windowTitle + '"')
  )
  if ($SmokeOnly) { $terminalArgs += '-Fast' }
  $terminal = Start-Process -FilePath 'conhost.exe' -ArgumentList $terminalArgs -PassThru

  $windowReady = $false
  for ($attempt = 0; $attempt -lt 80; $attempt += 1) {
    $windowProcess = Get-Process | Where-Object { $_.MainWindowTitle -eq $windowTitle } | Select-Object -First 1
    if ($windowProcess) { $windowReady = $true; break }
    Start-Sleep -Milliseconds 250
  }
  if (-not $windowReady) { throw 'Dedicated demo terminal did not become ready.' }

  & $ffmpeg -hide_banner -loglevel warning -y `
    -f gdigrab -framerate 15 -draw_mouse 0 -i "title=$windowTitle" -t $captureSeconds `
    -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2:color=0x081018" `
    -c:v libx264 -preset ultrafast -crf 20 $sourceVideo
  if ($LASTEXITCODE -ne 0) { throw 'Terminal capture failed.' }

  if ($SmokeOnly) {
    $probe = (& $ffprobe -v error -show_entries 'format=duration:stream=width,height' -of json $sourceVideo) | Out-String | ConvertFrom-Json
    if ([double]$probe.format.duration -lt 8) { throw 'Terminal capture smoke was too short.' }
    & $ffmpeg -hide_banner -loglevel error -y -ss '00:00:12' -i $sourceVideo -frames:v 1 (Join-Path $verificationDir 'smoke-frame.png')
    Write-Host "Terminal recording smoke passed: $($probe.format.duration) seconds."
    return
  }

  $narration = Join-Path $workDir 'narration.wav'
  $output = Join-Path $demoDir 'demo.webm'
  New-Narration $narration
  $sourceProbe = (& $ffprobe -v error -show_entries format=duration -of json $sourceVideo) | Out-String | ConvertFrom-Json
  $duration = [double]$sourceProbe.format.duration
  if ($duration -lt 180) { throw "Recorded workflow is too short: $duration seconds." }

  $audioFilter = "[1:a]apad=pad_dur=$duration[a]"
  & $ffmpeg -hide_banner -loglevel warning -y -i $sourceVideo -i $narration `
    -filter_complex $audioFilter -map 0:v:0 -map '[a]' `
    -c:v libvpx-vp9 -crf 38 -b:v 0 -deadline realtime -cpu-used 8 -row-mt 1 `
    -c:a libopus -b:a 64k -t $duration $output
  if ($LASTEXITCODE -ne 0) { throw 'Final demo encoding failed.' }

  & $ffmpeg -hide_banner -loglevel error -y -ss '00:01:35' -i $output -frames:v 1 (Join-Path $demoDir 'demo-thumbnail.png')
  $frameTimes = @('00:00:10','00:00:35','00:01:05','00:01:35','00:02:05','00:02:35','00:03:00','00:03:25','00:03:55','00:04:15')
  for ($index = 0; $index -lt $frameTimes.Count; $index += 1) {
    & $ffmpeg -hide_banner -loglevel error -y -ss $frameTimes[$index] -i $output -frames:v 1 (Join-Path $verificationDir ('{0:D2}-frame.png' -f ($index + 1)))
  }

  $probeJson = (& $ffprobe -v error -show_entries 'format=duration,size:stream=codec_type,codec_name,width,height' -of json $output) | Out-String
  $probe = $probeJson | ConvertFrom-Json
  $videoStream = $probe.streams | Where-Object { $_.codec_type -eq 'video' } | Select-Object -First 1
  $audioStream = $probe.streams | Where-Object { $_.codec_type -eq 'audio' } | Select-Object -First 1
  if ([double]$probe.format.duration -lt 180 -or $videoStream.width -ne 1280 -or $videoStream.height -ne 720 -or -not $audioStream) { throw 'Demo acceptance failed.' }

  $hash = (Get-FileHash -Algorithm SHA256 $output).Hash.ToLower()
  $evidence = [ordered]@{
    generated_at_utc = [DateTime]::UtcNow.ToString('o')
    duration_seconds = [Math]::Round([double]$probe.format.duration, 3)
    width = $videoStream.width
    height = $videoStream.height
    video_codec = $videoStream.codec_name
    audio_codec = $audioStream.codec_name
    capture = 'Dedicated Windows PowerShell terminal via FFmpeg gdigrab'
    data_boundary = 'Repository-curated public examples; all external providers and models disabled'
    workflow = 'Status -> rules -> history -> typed degradation -> provider gate -> HTTP security -> tests -> audit -> architecture'
    captions = 'demo-captions.vtt'
    sha256 = $hash
    bytes = (Get-Item $output).Length
    verification_frames = $frameTimes.Count
    frame_timestamps = $frameTimes
  }
  [IO.File]::WriteAllText((Join-Path $verificationDir 'verification.json'), ($evidence | ConvertTo-Json) + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
  [IO.File]::WriteAllText((Join-Path $demoDir 'demo.sha256'), "$hash  demo.webm$([Environment]::NewLine)", [Text.UTF8Encoding]::new($false))
  $evidence | ConvertTo-Json
} finally {
  if ($terminal -and -not $terminal.HasExited) { Stop-ProcessTree -ProcessId $terminal.Id }
}
