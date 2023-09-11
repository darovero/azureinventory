# Define Resource Group
$RGtoEval = $env:resourcegroup
$TagsToFilter = $env:tagsToFilter

# Function to discover resources within the Resource Group
function resourcegroup_discover {
    $selectedTags = "$TagsToFilter" -split ','

    $resources = az resource list --resource-group $RGtoEval --query '[].{Name:name, ResourceType:type, ResourceGroupName:resourceGroup, Location:location, Tags:tags}' --output json | ConvertFrom-Json
    
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

    $tagRows
}

$exportData = resourcegroup_discover
$exportData | Export-Csv "Resources_$RGtoEval.csv" -NoTypeInformation
