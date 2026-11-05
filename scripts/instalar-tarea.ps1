# Instala (o quita) la tarea programada de Windows que corre scripts/meta-local.ps1 todos los dias.
# Corre con tu usuario y solo cuando tu sesion esta iniciada (no necesita permisos de administrador).
#
#   powershell -ExecutionPolicy Bypass -File scripts\instalar-tarea.ps1              # todos los dias a las 08:00
#   powershell -ExecutionPolicy Bypass -File scripts\instalar-tarea.ps1 -Hora 09:30
#   powershell -ExecutionPolicy Bypass -File scripts\instalar-tarea.ps1 -Quitar
param([string]$Hora = '08:00', [switch]$Quitar)

$nombre = 'LibraryScrapping-Meta'
if ($Quitar) {
  Unregister-ScheduledTask -TaskName $nombre -Confirm:$false
  Write-Host "Tarea '$nombre' eliminada."
  exit 0
}

$script = Join-Path $PSScriptRoot 'meta-local.ps1'
$repo = Split-Path -Parent $PSScriptRoot
$accion = New-ScheduledTaskAction -Execute 'powershell.exe' -WorkingDirectory $repo `
  -Argument ('-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}"' -f $script)
$disparador = New-ScheduledTaskTrigger -Daily -At $Hora
# Si la PC estaba apagada a la hora, corre apenas se pueda; no corre con bateria baja ni dura mas de 1 hora.
$ajustes = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $nombre -Action $accion -Trigger $disparador -Settings $ajustes `
  -Description 'Library Scrapping: captura diaria de anuncios de Meta y publicacion en GitHub Pages' -Force | Out-Null

$info = Get-ScheduledTaskInfo -TaskName $nombre
Write-Host "Tarea '$nombre' programada todos los dias a las $Hora. Proxima corrida: $($info.NextRunTime)"
Write-Host "Correrla ahora:   Start-ScheduledTask -TaskName $nombre"
Write-Host "Ver el registro:  Get-Content .cache\meta-local.log -Tail 30"
