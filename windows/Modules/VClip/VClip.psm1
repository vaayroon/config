function vclipf {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Path
  )

  if (Test-Path $Path) {
    Get-Content -Raw -Path $Path | Set-Clipboard
    Write-Host "Contenido de '$Path' copiado al portapapeles."
  } else {
    Write-Error "El archivo '$Path' no existe."
  }
}

function vclip {
  param (
    [string]$Path
  )

  if ($Path) {
    if (Test-Path $Path) {
      Get-Content -Raw -Path $Path | Set-Clipboard
      Write-Host "Contenido de '$Path' copiado al portapapeles."
    } else {
      Write-Error "El archivo '$Path' no existe."
    }
  } else {
    $input | Set-Clipboard
    Write-Host "Texto desde stdin copiado al portapapeles."
  }
}
