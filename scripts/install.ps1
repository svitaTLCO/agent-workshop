#Requires -Version 5.1
# Windows installer (copy; symlinks need dev rights). Idempotent.
$root = Split-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) -Parent
$skills = Get-ChildItem "$root\skills" -Directory | Select-Object -ExpandProperty Name
foreach ($s in $skills) {
  foreach ($base in @("$HOME\.agents\skills", "$HOME\.config\opencode\skills", "$HOME\.claude\skills")) {
    New-Item -ItemType Directory -Force -Path $base | Out-Null
    Copy-Item "$root\skills\$s" "$base\$s" -Recurse -Force
    Write-Output "installed $s"
  }
}
Write-Output "done. In any agent say: init my agent"
