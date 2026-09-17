# Verify native-Windows agent prerequisites. Prints OK/WARN/FAIL; exits 1 on any FAIL.
$fails = 0
function Ok($m){ Write-Output "OK   $m" }
function Warn($m){ Write-Output "WARN $m" }
function Fail($m){ Write-Output "FAIL $m"; $script:fails++ }

if ($env:OS -ne 'Windows_NT' -and -not [bool](Get-Variable IsWindows -ValueOnly -ErrorAction SilentlyContinue)) {
    Warn "not running on Windows — verify-windows does not apply"; exit 0
}

if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSVersionTable.PSEdition -eq 'Core') {
    Ok "pwsh $($PSVersionTable.PSVersion)"
} else {
    Fail "PowerShell 7+ required (found $($PSVersionTable.PSVersion), edition $($PSVersionTable.PSEdition))"
}

try {
    $wv = (winget --version 2>$null) | Select-Object -First 1
    if ($wv) { Ok "winget $wv" } else { Warn "winget probe returned nothing (App Installer version too old?)" }
} catch {
    Warn "winget not found (install/repair App Installer, then re-run)"
}

$wslList = $null
try { $wslList = (wsl --list --quiet 2>$null) -join ',' } catch { $wslList = $null }
if ($wslList -and $wslList -notmatch 'No installed|There is no distribution') {
    Ok "WSL distro present: $wslList (env-wsl home available as an alternative; choice belongs to the user)"
} else {
    Warn "no WSL distro — native-only mode (install WSL2 if you want the env-wsl home later)"
}

if (($env:PATH -split ';').Count -gt 5) { Ok "PATH looks sane" } else { Warn "PATH unusually short — check per-user PATH" }

exit ([math]::Min($fails, 1))
