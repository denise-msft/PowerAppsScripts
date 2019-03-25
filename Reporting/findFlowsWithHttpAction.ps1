<#  
    Outputs a .csv file of records that represent a premium feature found in PowerApps and Flow 
    throughout the tenant it is run in. Result feature records will include:
        - HTTP Actions used in Flows

    PowerApps PowerShell installation instructions and documentation: https://docs.microsoft.com/en-us/powerapps/administrator/powerapps-powershell
#>

param(
    [string]$EnvironmentName,
    [string]$Path = './flowsWithHttpAction.csv'
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

    # check if flow uses HTTP action
    if ($flowDetails.Internal.properties.definitionSummary.actions -match 'Http')
    {
        $row = @{
            AffectedResourceType = 'Flow'
            DisplayName = $flowDetails.displayName
            Name = $flowDetails.flowName
            EnvironmentName = $flowDetails.environmentName
            ConnectorDisplayName = 'HTTP Action'
            CreatedByObjectId = $flowDetails.internal.properties.creator.objectId
            IsHttpAction = $true
        }
        $premiumFeatures += $(new-object psobject -Property $row)
    }
}

$premiumFeatures | Export-Csv -Path $Path
