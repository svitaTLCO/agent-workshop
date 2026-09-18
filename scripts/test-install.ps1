#Requires -Version 5.1
# Quality gate for scripts/install.ps1: throwaway project dirs asserting the same ownership
# contract as scripts/test-install.sh — refuse unmanaged targets (exit 2), replace marked ones.
$ErrorActionPreference = 'Stop'
$script:installer = Join-Path $PSScriptRoot 'install.ps1'
$cand = Get-Command powershell.exe -ErrorAction SilentlyContinue
if (-not $cand) { $cand = Get-Command pwsh }
$script:exe = $cand.Source
$script:tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('test-install-ps1-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $script:tempRoot | Out-Null
function Fail([string]$m) { Write-Host "FAIL: $m"; exit 1 }
function New-Scratch([string]$name) {
  $d = Join-Path $script:tempRoot $name
  New-Item -ItemType Directory -Path $d | Out-Null
  return $d
}
function Invoke-Installer([string[]]$arglist, [string]$cwd) {
  $run = Start-Process -FilePath $script:exe -WorkingDirectory $cwd -Wait -PassThru -NoNewWindow `
    -RedirectStandardOutput (Join-Path $script:tempRoot 'stdout.log') `
    -RedirectStandardError (Join-Path $script:tempRoot 'stderr.log') `
    -ArgumentList (@('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $script:installer) + $arglist)
  return $run.ExitCode
}
function TreeCount([string]$d) {
  (Get-ChildItem -LiteralPath $d -Force -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
}
try {
  $p1 = New-Scratch 'c1-unmanaged'
  $t1 = Join-Path $p1 '.opencode/skills/context-diet'
  New-Item -ItemType Directory -Path $t1 | Out-Null
  Set-Content -LiteralPath (Join-Path $t1 'user.txt') -Value 'keep'
  $rc = Invoke-Installer @('-Agents','opencode','-Skills','context-diet','-Project') $p1
  if ($rc -ne 2) { Fail "case1: expected refusal exit 2, got $rc" }
  if (-not (Test-Path -LiteralPath (Join-Path $t1 'user.txt'))) { Fail 'case1: user.txt deleted' }
  if (-not (Select-String -LiteralPath (Join-Path $script:tempRoot 'stderr.log') -Pattern 'refusing to replace unmanaged' -Quiet)) { Fail 'case1: refusal message missing' }
  Write-Output 'ok: refuses unmanaged target (exit 2, content preserved)'

  $p2 = New-Scratch 'c2-managed'
  $t2 = Join-Path $p2 '.opencode/skills/context-diet'
  New-Item -ItemType Directory -Path $t2 | Out-Null
  Set-Content -LiteralPath (Join-Path $t2 '.agent-workshop-installed') -Value 'agent-workshop'
  Set-Content -LiteralPath (Join-Path $t2 'obsolete.txt') -Value 'old'
  $rc = Invoke-Installer @('-Agents','opencode','-Skills','context-diet','-Project') $p2
  if ($rc -ne 0) { Fail "case2: expected exit 0, got $rc" }
  if (Test-Path -LiteralPath (Join-Path $t2 'obsolete.txt')) { Fail 'case2: obsolete content survived' }
  if (-not (Test-Path -LiteralPath (Join-Path $t2 'SKILL.md'))) { Fail 'case2: SKILL.md missing after re-copy' }
  if (-not (Test-Path -LiteralPath (Join-Path $t2 '.agent-workshop-installed') -PathType Leaf)) { Fail 'case2: marker missing' }
  Write-Output 'ok: replaces marked managed target (obsolete removed, SKILL.md + marker present)'

  $p3 = New-Scratch 'c3-invalid'
  $before = TreeCount $p3
  $rcA = Invoke-Installer @('-Agents','bogus','-Skills','context-diet','-Project') $p3
  if ($rcA -eq 0) { Fail 'case3: invalid agent accepted' }
  if ((TreeCount $p3) -ne $before) { Fail 'case3: invalid agent created output' }
  $rcB = Invoke-Installer @('-Agents','opencode','-Skills','nosuch-skill','-Project') $p3
  if ($rcB -eq 0) { Fail 'case3: invalid skill accepted' }
  if ((TreeCount $p3) -ne $before) { Fail 'case3: invalid skill created output' }
  Write-Output 'ok: invalid agent/skill rejected (non-zero, no output)'
}
finally {
  Remove-Item -LiteralPath $script:tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Output 'test-install-ps1: all checks passed'
