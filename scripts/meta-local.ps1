# Captura diaria de Meta desde esta PC (Meta entrega la lista completa a un navegador normal; a los servidores de
# GitHub solo la primera pagina). Trae lo publicado, captura Meta de todas las marcas y publica en gh-pages.
# La tarea programada de Windows (scripts/instalar-tarea.ps1) ejecuta exactamente esto.
#
#   powershell -ExecutionPolicy Bypass -File scripts\meta-local.ps1
param([string]$Only = '')

$ErrorActionPreference = 'Continue'
$repo = Split-Path -Parent $PSScriptRoot
$log = Join-Path $repo '.cache\meta-local.log'
New-Item -ItemType Directory -Force (Join-Path $repo '.cache') | Out-Null
function Log($m) { $l = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; Write-Host $l; Add-Content -Path $log -Value $l -Encoding UTF8 }

# Node portable (sin instalador): primero el de la carpeta tools del usuario, si no, el del PATH.
$nodeDir = Get-ChildItem (Join-Path $env:USERPROFILE 'tools') -Directory -Filter 'node-v*-win-x64' -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1
if (-not $nodeDir -and (Test-Path 'D:\Usuarios\IR72078093\tools')) {
  $nodeDir = Get-ChildItem 'D:\Usuarios\IR72078093\tools' -Directory -Filter 'node-v*-win-x64' | Sort-Object Name | Select-Object -Last 1
}
if ($nodeDir) { $env:Path = "$($nodeDir.FullName);$env:Path" }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Log 'No se encontro Node. Revisa la carpeta tools.'; exit 1 }

Set-Location $repo
Log "=== Inicio captura Meta (node $(node --version)) ==="

# Lo subido a main (marcas, palabra clave, fechas) entra en la corrida de hoy.
$env:GIT_TERMINAL_PROMPT = '0'
git pull -q --ff-only origin main 2>&1 | ForEach-Object { Log "git: $_" }
npm install --no-audit --no-fund --silent 2>&1 | Out-Null

# Lo publicado: hace falta para comparar con el dia anterior y no repetir miniaturas.
$stage = Join-Path $repo '.cache\local-site'
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $stage | Out-Null
git fetch -q origin gh-pages 2>&1 | Out-Null
# Con cmd: en PowerShell 5.1 el "|" entre programas corrompe datos binarios.
cmd /c "git archive FETCH_HEAD | tar -x -C `"$stage`""
$env:OUT_DIR = $stage

$captureArgs = @('--no-deprecation', 'src/capture.js', '--source', 'meta')
if ($Only) { $captureArgs += @('--only', $Only) }
node @captureArgs 2>&1 | ForEach-Object { Log $_ }
if ($LASTEXITCODE -ne 0) { Log 'La captura fallo.'; exit 1 }

node --no-deprecation src/publish.js --from $stage --keep-dashboard 2>&1 | ForEach-Object { Log $_ }
$status = $LASTEXITCODE
Log ("=== Fin - {0} ===" -f ($(if ($status -eq 0) { 'OK' } else { 'con errores' })))
exit $status
