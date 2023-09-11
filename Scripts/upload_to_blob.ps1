param(
    [string]$resourceGroup,
    [string]$containerName,
    [string]$blobName,
    [string]$storageAccountName,
    [string]$storageAccountKey
)

# Instala el módulo Az.Storage si no está instalado
if (-not (Get-Module -Name Az.Storage -ListAvailable)) {
    Install-Module -Name Az.Storage -Force -AllowClobber
}

# Conectarse a la cuenta de almacenamiento de Azure
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Ruta al archivo local que deseas cargar en el Blob Storage
$localFilePath = "Resources_$resourceGroup.csv"  # Debes asegurarte de que este archivo exista en la ubicación correcta

# Cargar el archivo en el Blob Storage
Set-AzStorageBlobContent -Context $context -Container $containerName -File $localFilePath -Blob $blobName -Force

Write-Host "El archivo $localFilePath se ha cargado en el contenedor $containerName con el nombre de blob $blobName."
