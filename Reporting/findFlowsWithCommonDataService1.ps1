<#  
    Outputs a .csv file of records that represent a premium feature found in Flow 
    throughout the tenant it is run in. Result feature records will include:
        - Flows using the Common Data Service 1.0 (old version)

    PowerApps PowerShell installation instructions and documentation: https://docs.microsoft.com/en-us/powerapps/administrator/powerapps-powershell
#>

param(
    [string]$EnvironmentName,
    [string]$Path = './flowsWithCds1.csv'
)

if (-not [string]::isNullOrEmpty($EnvironmentName))
{
    $flows = Get-AdminFlow -EnvironmentName $EnvironmentName
}
else 
{
    $flows = Get-AdminFlow
}

$premiumFeatures = @()

# loop through flows
foreach ($flow in $flows)
{
    $flowDetails = $flow | Get-AdminFlow

    # loop through each connection reference
    foreach($conRef in $flowDetails.Internal.properties.connectionReferences)
    {
        foreach($connection in $conRef)
        {
            foreach ($connId in ($connection | Get-Member -MemberType NoteProperty).Name) 
            {
                $connDetails = $($connection.$connId)
                if ($connDetails.id -eq '/providers/Microsoft.PowerApps/apis/shared_runtimeservice' )
                {
                    $row = @{
                        AffectedResourceType = 'Flow'
                        DisplayName = $flowDetails.displayName
                        Name = $flowDetails.flowName
                        EnvironmentName = $flowDetails.environmentName
                        ConnectorDisplayName = $connDetails.displayName
                        ConnectionId = $connDetails.id
                        ConnectionName = $connDetails.connectionName
                        CreatedByObjectId = $flowDetails.internal.properties.creator.objectId
                    }
                    $premiumFeatures += $(new-object psobject -Property $row)
                }
            }
        }        
    }
}

$premiumFeatures | Export-Csv -Path $Path
