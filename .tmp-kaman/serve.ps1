$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$port = 8123
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$port/")
$listener.Start()
Write-Output "serving $root on http://127.0.0.1:$port/"
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
  if ([string]::IsNullOrWhiteSpace($rel)) { $rel = 'kaman-export/kaman-prototype.html' }
  $path = Join-Path $root ($rel -replace '/', [IO.Path]::DirectorySeparatorChar)
  $full = [IO.Path]::GetFullPath($path)
  if (-not $full.StartsWith([IO.Path]::GetFullPath($root))) {
    $ctx.Response.StatusCode = 403; $ctx.Response.Close(); continue
  }
  if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
    Write-Output ("404 /" + $rel)
    $ctx.Response.StatusCode = 404; $ctx.Response.Close(); continue
  }
  $bytes = [IO.File]::ReadAllBytes($full)
  $ext = [IO.Path]::GetExtension($full).ToLowerInvariant()
  $ctx.Response.Headers.Add('Cache-Control', 'no-store')
  $ctx.Response.ContentType = switch ($ext) {
    '.html' { 'text/html; charset=utf-8' }
    '.js'   { 'text/javascript; charset=utf-8' }
    '.css'  { 'text/css; charset=utf-8' }
    '.png'  { 'image/png' }
    default { 'application/octet-stream' }
  }
  $ctx.Response.ContentLength64 = $bytes.Length
  $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  $ctx.Response.Close()
  Write-Output ("200 /" + $rel)
}
