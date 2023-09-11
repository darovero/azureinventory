param(
    [string]$resourceGroup,
    [string]$tagsToFilter,
    [string]$outputFilePath
)

Write-Host "resourceGroup: $resourceGroup"
Write-Host "tagsToFilter: $tagsToFilter"
Write-Host "outputFilePath: $outputFilePath"


# Convertir la cadena de tags a una lista de tags
$selectedTags = $tagsToFilter -split ','

# Obtener la lista de recursos en el grupo de recursos
$resources = az resource list --resource-group $resourceGroup --query '[].{Name:name, ResourceType:type, ResourceGroupName:resourceGroup, Location:location, Tags:tags}' --output json | ConvertFrom-Json

# Crear una lista para almacenar los resultados
$tagRows = @()

foreach ($resource in $resources) {
    $tagRow = [PSCustomObject]@{
        Name            = $resource.Name
        ResourceType    = $resource.ResourceType
        ResourceGroupName = $resource.ResourceGroupName
        Location        = $resource.Location
    }

    $resourceTags = $resource.Tags

    if ($resourceTags) {
        foreach ($tagName in $selectedTags) {
            $tagValue = $resourceTags.$tagName
            $tagRow | Add-Member -MemberType NoteProperty -Name $tagName -Value $tagValue
        }
    } else {
        foreach ($tagName in $selectedTags) {
            $tagRow | Add-Member -MemberType NoteProperty -Name $tagName -Value ""
        }
    }

    $tagRows += $tagRow
}

# Exportar los resultados a un archivo CSV
$tagRows | Export-Csv $outputFilePath -NoTypeInformation