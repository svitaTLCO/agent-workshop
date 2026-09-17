# Live triage for coding agents on Windows (complements verify-windows.ps1 prerequisites).
# Prints OK/WARN/FAIL; exits 1 on any FAIL. Graceful off-platform degrade.
$fails = 0
function Ok($m){ Write-Output "OK   $m" }
function Warn($m){ Write-Output "WARN $m" }
function Fail($m){ Write-Output "FAIL $m"; $script:fails++ }

if ($env:OS -ne 'Windows_NT' -and -not [bool](Get-Variable IsWindows -ValueOnly -ErrorAction SilentlyContinue)) {
    Warn "not running on Windows — diagnose-windows does not apply"; exit 0
}

try {
    $enc = [Console]::OutputEncoding.WebName
    if ($enc -eq 'utf-8') { Ok "console encoding UTF-8" } else { Warn "console encoding is $enc — set [Console]::OutputEncoding=[Text.Encoding]::UTF8" }
} catch { Warn "console encoding unreadable (redirected/non-interactive)" }

try {
    $codepage = ([string](chcp)) -replace '[^0-9]', ''
    if ($codepage -eq '65001') { Ok "active codepage 65001 (UTF-8)" } else { Warn "codepage $codepage — start cmd chains with 'chcp 65001 >`$null'" }
} catch { Warn "codepage probe failed" }

if ($ProgressPreference -eq 'SilentlyContinue') { Ok "progress suppressed (fast REST calls)" } else { Warn "set \$ProgressPreference='SilentlyContinue' in agent sessions" }

$docs = [Environment]::GetFolderPath('MyDocuments')
if ($docs -like "$env:OneDrive*") { Warn "Documents redirected to OneDrive ($docs) — use the real path everywhere" } else { Ok "Documents not OneDrive-redirected" }

$freeGb = [math]::Round((Get-PSDrive C).Free / 1GB, 0)
if ($freeGb -ge 20) { Ok "C: free ${freeGb} GB (model/image headroom ok)" } else { Warn "C: free ${freeGb} GB < 20 — defer pulls or free space (see Docker VHD)" }

try {
    $conns = Get-NetTCPConnection -LocalPort 11434 -State Listen -ErrorAction SilentlyContinue
    if (-not $conns) { Ok "port 11434 free" }
    else {
        $names = @($conns | Select-Object -ExpandProperty OwningProcess -Unique | ForEach-Object { (Get-Process -Id $_ -ErrorAction SilentlyContinue).ProcessName })
        if ($names -join ',' -match 'ollama') { Ok "port 11434 held by ollama" } else { Warn "port 11434 held by: $($names -join ', ') (ollama cannot bind until freed)" }
    }
} catch { Warn "port 11434 probe failed" }

if (Get-Command git -ErrorAction SilentlyContinue) {
    $al = git config --global core.autocrlf 2>$null
    $lp = git config --global core.longpaths 2>$null
    if ($al -eq 'input') { Ok "git core.autocrlf=input" } else { Warn "git core.autocrlf='$al' — set 'input' (LF per repo .gitattributes)" }
    if ($lp -eq 'true') { Ok "git core.longpaths=true" } else { Warn "git core.longpaths='$lp' — deep trees need true + LongPathsEnabled=1" }
} else { Warn "git not installed" }

$vswhere = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    $vcRoot = & $vswhere -latest -property installationPath 2>$null
    if ($vcRoot) { Ok "MSVC install found: $vcRoot" } else { Warn "vswhere present but no VS/BuildTools install (native builds blocked)" }
} else { Warn "VS Build Tools not detected (fine unless native builds are expected)" }

exit ([math]::Min($fails, 1))
