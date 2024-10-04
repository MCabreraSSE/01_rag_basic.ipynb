#.\RAG1-RecorreyListaFiles.ps1 -rutaDirectorio "C:\Ruta\A\Tu\Directorio" -archivoSalida "C:\Ruta\A\Tu\ArchivoSalida.txt" -soloNombre

#[switch]$soloNombre: Este parámetro es opcional. solo se guardará el nombre del archivo

param (
    [string]$rutaDirectorio,   # Ruta del directorio especificada como parámetro
    [string]$archivoSalida,    # Ruta del archivo donde se guardarán los nombres de los archivos
    [switch]$soloNombre        # Si se usa este switch, se guardará solo el nombre del archivo en lugar de la ruta completa
)

# Verifica si la ruta existe
if (-Not (Test-Path -Path $rutaDirectorio)) {
    Write-Host "La ruta especificada no existe. Por favor, verifica la ruta." -ForegroundColor Red
    exit
}

# Recorre recursivamente todos los archivos en la ruta especificada
Get-ChildItem -Path $rutaDirectorio -Recurse | ForEach-Object {
    # Verifica si el elemento es un archivo
    if (-not $_.PSIsContainer) {
        if ($soloNombre) {
            # Escribe solo el nombre del archivo
            $_.Name | Out-File -Append -FilePath $archivoSalida
        } else {
            # Escribe la ruta completa del archivo
            $_.FullName | Out-File -Append -FilePath $archivoSalida
        }
    }
}

Write-Host "Proceso completado. Los nombres de los archivos han sido guardados en $archivoSalida." -ForegroundColor Green
