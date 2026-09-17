#Requires -Version 5.1
# Per-agent installer, copy mode only (symlinks need dev mode/admin). Idempotent.
# Usage: powershell -ExecutionPolicy Bypass -File scripts/install.ps1 [-Agents a[,b]] [-Skills s[,t]] [-Project]
# Agents: opencode, claude-code (alias: claude), codex, pi, cursor, aider. Omit -Agents to auto-detect.
# Adapter table mirrored in docs/compatibility.md. Not yet executed on a Windows host; verify with:
#   powershell -File scripts/install.ps1 -Agents opencode -Skills context-diet -Project
# then check .opencode\skills and .claude\skills were created under the current directory.
param([string[]]$Agents = @(), [string[]]$Skills = @(), [switch]$Project)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$skillroot = Join-Path $root 'skills'
$all = @('opencode','claude-code','codex','pi','cursor','aider')
function Test-AgentPresent($bin, $dir) {
  [bool](Get-Command $bin -ErrorAction SilentlyContinue) -or ($dir -ne '' -and (Test-Path (Join-Path $HOME $dir)))
}
$agents = foreach ($a in $Agents) {
  if ($a -eq 'claude') { $a = 'claude-code' }
  if ($all -notcontains $a) { throw "unknown agent: $a (valid: $($all -join ', '))" }
  $a
}
if (-not $agents) {
  $pairs = @(
    @('opencode', '.config\opencode'), @('claude-code', '.claude'), @('codex', '.codex'),
    @('pi', '.pi'), @('cursor', '.cursor'), @('aider', '.aider.conf.yml'))
  $agents = foreach ($p in $pairs) { if (Test-AgentPresent $p[0] $p[1]) { $p[0] } }
}
if (-not $agents) { $agents = $all }
$known = Get-ChildItem $skillroot -Directory | Select-Object -ExpandProperty Name
if (-not $Skills) {
  $skills = $known
} else {
  $skills = foreach ($s in $Skills) {
    if ($known -notcontains $s) { throw "unknown skill: $s (valid: $($known -join ', '))" }
    $s
  }
}
$scope = if ($Project) { 'project' } else { 'global' }
$p = if ($Project) { (Get-Location).Path } else { $HOME }
function Get-SkillBase($agent) {
  switch ($agent) {
    'opencode'    { if ($Project) { Join-Path $p '.opencode\skills' } else { Join-Path $HOME '.config\opencode\skills' } }
    'claude-code' { if ($Project) { Join-Path $p '.claude\skills' } else { Join-Path $HOME '.claude\skills' } }
    default       { if ($Project) { Join-Path $p '.agents\skills' } else { Join-Path $HOME '.agents\skills' } }
  }
}
$bases = @((foreach ($a in $agents) { Get-SkillBase $a }) | Sort-Object -Unique)
$marker = '.agent-workshop-installed'
$n = 0
foreach ($base in $bases) {
  New-Item -ItemType Directory -Force -Path $base | Out-Null
  foreach ($s in $skills) {
    $dst = Join-Path $base $s
    if ((Test-Path $dst -PathType Container) -and -not (Test-Path (Join-Path $dst $marker))) {
      Write-Warning "replacing unmanaged $dst (move it away first if you edited it)"
    }
    if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
    Copy-Item (Join-Path $skillroot $s) $dst -Recurse
    Set-Content -Path (Join-Path $dst $marker) -Value 'agent-workshop'
    $n++
    Write-Output "-> [$scope/copy] $dst"
  }
}
Write-Output "installed $n copy(s) into $($bases.Count) path(s) for agents: $($agents -join ', '). In any agent say: init my agent"
