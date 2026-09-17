param(
  [string]$Steps = '',
  [string]$Out = 'shot.png',
  [int]$W = 480,
  [int]$H = 1130,
  [int]$Budget = 22000
)
$ErrorActionPreference = 'Stop'
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path $chrome)) { $chrome = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }
$outPath = Join-Path $PSScriptRoot $Out
if (Test-Path $outPath) { Remove-Item $outPath -Force }
$profileDir = Join-Path $env:TEMP ('kmshot-' + [guid]::NewGuid().ToString('N'))
$url = "http://127.0.0.1:8123/.tmp-kaman/probe.html?w=$W&h=$H&s=$([System.Uri]::EscapeDataString($Steps))"
$args = @(
  '--headless=new', '--disable-gpu', '--hide-scrollbars', '--no-first-run', '--no-default-browser-check',
  "--user-data-dir=$profileDir",
  "--virtual-time-budget=$Budget",
  "--window-size=$W,$H",
  "--screenshot=$outPath",
  $url
)
& $chrome @args
if (-not (Test-Path $outPath)) { throw "screenshot missing: $outPath" }
Write-Output $outPath
