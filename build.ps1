# Build the local fork and stage it where the DSH profile can install it.
# Usage: pwsh -File build.ps1 [-ProfileDir <path>]
param(
  [string]$ProfileDir = (Join-Path $HOME '.dsh\profiles\desktop')
)

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

Write-Host '== npm install (bundles openhongguo) =='
npm install --no-audit --no-fund --loglevel=error
if ($LASTEXITCODE -ne 0) { throw "npm install failed ($LASTEXITCODE)" }

Write-Host '== npm pack =='
Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.tgz' | Remove-Item -Force
npm pack --loglevel=error | Out-Null
if ($LASTEXITCODE -ne 0) { throw "npm pack failed ($LASTEXITCODE)" }
$tgz = Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.tgz' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $tgz) { throw 'npm pack produced no tarball' }
Write-Host "packed: $($tgz.Name) ($($tgz.Length) bytes)"

if (-not (Test-Path -LiteralPath $ProfileDir)) { throw "profile dir not found: $ProfileDir" }
$target = Join-Path $ProfileDir $tgz.Name
Copy-Item -LiteralPath $tgz.FullName -Destination $target -Force
Write-Host "copied to: $target"
Write-Host ''
Write-Host "Install it with the plugin manager: install_bundle target = file:./$($tgz.Name)"
