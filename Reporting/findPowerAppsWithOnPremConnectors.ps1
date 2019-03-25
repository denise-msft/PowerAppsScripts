<#  
    Outputs a .csv file of records that represent each premium feature found in PowerApps and Flows 
    throughout the tenant it is run in. Result feature records will include:
        - Connections to On Prem Connectors used in PowerApps

    PowerApps PowerShell installation instructions and documentation: https://docs.microsoft.com/en-us/powerapps/administrator/powerapps-powershell
#>

param(
    [string]$EnvironmentName,
    [string]$Path = './powerAppsOnPremConnections.csv'
)

if (-not [string]::isNullOrEmpty($EnvironmentName))
{
    $apps = Get-AdminPowerApp -EnvironmentName $EnvironmentName
}
else 
{
    $apps = Get-AdminPowerApp 
}

$premiumFeatures = @()

# loop through each app
foreach ($app in $apps)
{
    # loop through each connection reference
    foreach($conRef in $app.Internal.properties.connectionReferences)
    {
        foreach($connection in $conRef)
        {
            foreach ($connId in ($connection | Get-Member -MemberType NoteProperty).Name) 
            {
                $connDetails = $($connection.$connId)

                # save connection details if the connector is on prem
                if ($connDetails.isOnPremiseConnection)
                {
                    $row = @{
                        ResourceType = 'PowerApp'
                        DisplayName = $app.displayName
                        Name = $app.appName
                        EnvironmentName = $app.environmentName
                        ConnectorDisplayName = $connDetails.displayName
                        ConnectionId = $connDetails.id
                        ConnectionName = $connDetails.connectionName
                        CreatedByObjectId = $app.owner.id
                        CreatedByEmail = $app.owner.email
                        IsOnPremiseConnection = $connDetails.isOnPremiseConnection
                    }
                    $premiumFeatures += $(new-object psobject -Property $row)
                }
            }
        }        
    }
}

# output to file
$premiumFeatures | Export-Csv -Path $Path
