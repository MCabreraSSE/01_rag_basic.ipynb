#.\RAG1-AnalizaDirectorios.ps1 -rutaDirectorio "C:\Ruta\A\Tu\Directorio" -archivoSalida "C:\Ruta\A\Tu\ArchivoSalida.txt" -soloNombre

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

# Inicializa un hashtable para contar las extensiones
$conteoExtensiones = @{}

# Recorre recursivamente todos los archivos en la ruta especificada
Get-ChildItem -Path $rutaDirectorio -Recurse | ForEach-Object {
    # Verifica si el elemento es un archivo
    if (-not $_.PSIsContainer) {
        # Contabiliza las extensiones de los archivos, si no tiene extensión usa "SinExtension"
        $extension = if ($_.Extension) { $_.Extension.ToLower() } else { "SinExtension" }

        if ($conteoExtensiones.ContainsKey($extension)) {
            $conteoExtensiones[$extension]++
        } else {
            $conteoExtensiones[$extension] = 1
        }

        # Escribe el nombre o la ruta completa del archivo según el parámetro $soloNombre
        if ($soloNombre) {
            $_.Name | Out-File -Append -FilePath $archivoSalida
        } else {
            $_.FullName | Out-File -Append -FilePath $archivoSalida
        }
    }
}

# Verifica si el archivo CSV existe, si existe lo borra para evitar duplicados
$archivoConteo = "contador_aux.csv"
if (Test-Path $archivoConteo) {
    Remove-Item $archivoConteo
}

# Escribir el conteo de extensiones en el archivo CSV "contador_aux.csv"
"Extensión,Conteo" | Out-File -FilePath $archivoConteo  # Encabezado del CSV
$conteoExtensiones.GetEnumerator() | ForEach-Object {
    "$($_.Key),$($_.Value)" | Out-File -Append -FilePath $archivoConteo
}

Write-Host "Proceso completado. Los nombres de los archivos han sido guardados en $archivoSalida."
Write-Host "El conteo de extensiones ha sido guardado en $archivoConteo." -ForegroundColor Green
