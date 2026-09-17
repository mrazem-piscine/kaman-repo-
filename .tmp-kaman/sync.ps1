$ErrorActionPreference = 'Stop'

# Re-embeds source/Kaman App Motion.dc.html into the __bundler/template payload
# of kaman-export/kaman-prototype.html. Verified byte-identical on a no-op run.

function Convert-SourceToTemplate([string]$text) {
  $void = 'area','base','br','col','embed','hr','img','input','link','meta','param','source','track','wbr'
  $rxSelf = [regex]'<(?<t>[a-zA-Z][\w-]*)(?<a>(?:"[^"]*"|''[^'']*''|[^>"''])*?)\s*/>'
  $text = $rxSelf.Replace($text, {
    param($m)
    $t = $m.Groups['t'].Value; $a = $m.Groups['a'].Value
    if ($void -contains $t.ToLower()) { '<' + $t + $a + '>' } else { '<' + $t + $a + '></' + $t + '>' }
  })
  $rxCamel = [regex]'(?<= )(?<n>[A-Za-z]+[A-Z][A-Za-z]*)(?==")'
  $text = $rxCamel.Replace($text, {
    param($m)
    $n = $m.Groups['n'].Value
    'sc-camel-' + ([regex]::Replace($n, '([a-z0-9])([A-Z])', '$1-$2')).ToLower()
  })
  $text.Replace('<script type="text/x-dc" data-dc-script data-props=', '<script type="text/x-dc" data-dc-script="" data-props=')
}

function Encode-JsonString([string]$s) {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('"')
  for ($i = 0; $i -lt $s.Length; $i++) {
    $ch = $s[$i]
    switch ($ch) {
      '"'  { [void]$sb.Append('\"'); continue }
      '\'  { [void]$sb.Append('\\'); continue }
      "`n" { [void]$sb.Append('\n'); continue }
      "`r" { [void]$sb.Append('\r'); continue }
      "`t" { [void]$sb.Append('\t'); continue }
      "`b" { [void]$sb.Append('\b'); continue }
      "`f" { [void]$sb.Append('\f'); continue }
      '/'  { if ($i -gt 0 -and $s[$i - 1] -eq '<') { [void]$sb.Append('\u002F') } else { [void]$sb.Append('/') }; continue }
      default {
        if ([int]$ch -lt 32) { [void]$sb.Append(('\u{0:x4}' -f [int]$ch)) } else { [void]$sb.Append($ch) }
      }
    }
  }
  [void]$sb.Append('"')
  $sb.ToString()
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$root = Split-Path -Parent $PSScriptRoot
$bundlePath = Join-Path $root 'kaman-export\kaman-prototype.html'
$srcPath = Join-Path $root 'kaman-export\source\Kaman App Motion.dc.html'

$bundle = [System.IO.File]::ReadAllText($bundlePath, [System.Text.Encoding]::UTF8)
$src = [System.IO.File]::ReadAllText($srcPath, [System.Text.Encoding]::UTF8)

$openTag = '<script type="__bundler/template">'
$o = $bundle.IndexOf($openTag)
if ($o -lt 0) { throw 'template script tag not found' }
$jsonStart = $bundle.IndexOf('"', $o + $openTag.Length)
$jsonEnd = $bundle.IndexOf("`n", $jsonStart)
if ($bundle[$jsonEnd - 1] -eq "`r") { $jsonEnd-- }
$origJson = $bundle.Substring($jsonStart, $jsonEnd - $jsonStart)

$html = $origJson | ConvertFrom-Json
$marker = '<div dir="{{ dirVal }}" style="position:fixed;inset:0;'
$closer = '</script>'

$hStart = $html.IndexOf($marker)
$hEnd = $html.LastIndexOf($closer) + $closer.Length
$sStart = $src.IndexOf($marker)
$sEnd = $src.LastIndexOf($closer) + $closer.Length
if ($hStart -lt 0 -or $sStart -lt 0) { throw 'region marker not found' }

$region = Convert-SourceToTemplate $src.Substring($sStart, $sEnd - $sStart)
$newHtml = $html.Substring(0, $hStart) + $region + $html.Substring($hEnd)
$newJson = Encode-JsonString $newHtml

if ($newJson -ceq $origJson) {
  Write-Output 'template unchanged (byte-identical) - nothing written'
} else {
  $out = $bundle.Substring(0, $jsonStart) + $newJson + $bundle.Substring($jsonEnd)
  [System.IO.File]::WriteAllText($bundlePath, $out, $utf8)
  Write-Output ('template updated: ' + $origJson.Length + ' -> ' + $newJson.Length + ' chars')
}
