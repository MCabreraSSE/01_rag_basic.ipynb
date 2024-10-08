# powershell -ExecutionPolicy Bypass -File .\RAG1-Duplicados.ps1 "E:\Documentacion"

param(
    [string]$FolderPath
)

if (-not (Test-Path -Path $FolderPath)) {
    Write-Host "La ruta especificada no es válida. Por favor, proporciona una ruta válida." -ForegroundColor Red
    exit
}

# Obtener todos los archivos de la carpeta y subcarpetas
$files = Get-ChildItem -Path $FolderPath -File -Recurse

# Crear un Hashtable para agrupar archivos por tamaño
$fileGroups = @{}
foreach ($file in $files) {
    $size = $file.Length
    if (-not $fileGroups.ContainsKey($size)) {
        $fileGroups[$size] = @()
    }
    $fileGroups[$size] += $file
}

# Buscar archivos con el mismo tamaño y comparar sus contenidos
$duplicates = @()
foreach ($group in $fileGroups.Values) {
    if ($group.Count -gt 1) {
        $hashTable = @{}
        foreach ($file in $group) {
            $hash = (Get-FileHash -Path $file.FullName).Hash
            if ($hashTable.ContainsKey($hash)) {
                $hashTable[$hash] += $file
            } else {
                $hashTable[$hash] = @($file)
            }
        }
        foreach ($hashGroup in $hashTable.Values) {
            if ($hashGroup.Count -gt 1) {
                for ($i = 0; $i -lt $hashGroup.Count; $i++) {
                    for ($j = $i + 1; $j -lt $hashGroup.Count; $j++) {
                        $duplicates += [PSCustomObject]@{
                            File1 = $hashGroup[$i].FullName
                            File2 = $hashGroup[$j].FullName
                        }
                    }
                }
            }
        }
    }
}

# Guardar los archivos duplicados en un archivo CSV
$outputPath = "duplicados.csv"
$duplicates | Export-Csv -Path $outputPath -NoTypeInformation

# Mostrar los archivos duplicados y el total
if ($duplicates.Count -eq 0) {
    Write-Host "No se encontraron archivos duplicados en la carpeta especificada." -ForegroundColor Green
} else {
    Write-Host "Archivos duplicados encontrados:" -ForegroundColor Yellow
    $duplicates | ForEach-Object {
        Write-Host "Duplicado: $_.File1 y $_.File2"
    }
    Write-Host "Total de archivos duplicados encontrados: $($duplicates.Count)" -ForegroundColor Cyan
    Write-Host "Listado de duplicados guardado en: $outputPath" -ForegroundColor Cyan
}
