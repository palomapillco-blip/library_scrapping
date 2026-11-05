# Instala (o quita) la tarea programada de Windows que corre scripts/meta-local.ps1 todos los dias.
# Corre con tu usuario y solo cuando tu sesion esta iniciada (no necesita permisos de administrador).
#
#   powershell -ExecutionPolicy Bypass -File scripts\instalar-tarea.ps1              # todos los dias a las 08:00
#   powershell -ExecutionPolicy Bypass -File scripts\instalar-tarea.ps1 -Hora 09:30
#   powershell -ExecutionPolicy Bypass -File scripts\instalar-tarea.ps1 -Quitar
param([string]$Hora = '08:00', [switch]$Quitar)

$nombre = 'LibraryScrapping-Meta'
if ($Quitar) { schtasks /Delete /TN $nombre /F; exit $LASTEXITCODE }

$script = Join-Path $PSScriptRoot 'meta-local.ps1'
$accion = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`""
schtasks /Create /TN $nombre /TR $accion /SC DAILY /ST $Hora /F
if ($LASTEXITCODE -eq 0) {
  Write-Host "Tarea '$nombre' programada todos los dias a las $Hora."
  Write-Host "Correrla ahora:   schtasks /Run /TN $nombre"
  Write-Host "Ver el registro:  Get-Content .cache\meta-local.log -Tail 30"
}
exit $LASTEXITCODE
