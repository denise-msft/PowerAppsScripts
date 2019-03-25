<#  
    Outputs a .csv file of records that represent a premium feature found in PowerApps and Flow 
    throughout the tenant it is run in. Result feature records will include:
        - Custom Connectors used in Flows

    PowerApps PowerShell installation instructions and documentation: 
    https://docs.microsoft.com/en-us/powerapps/administrator/powerapps-powershell

    Requirements:
    - Azure AD (PS module) (https://www.powershellgallery.com/packages/AzureAD/)
    - PowerApps Admin (PS module) (https://www.powershellgallery.com/packages/Microsoft.PowerApps.Administration.PowerShell)
    - Global tenant admin account or account with BAP Admin permissions
    - PowerApps Plan 2 license
    - Configure PS execution policy to remote signed (Set-ExecutionPolicy RemoteSigned)

    Example Input:
    .\findFlowsWithCustomConnectors
#>

param(
    [string]$EnvironmentName,
    [string]$Path = './flowsWithCustomConnectors.csv',
    [Parameter(Mandatory=$true)]
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$Password
)

# check if Azure AD module installed
if (Get-Module -ListAvailable -Name AzureAD) 
{
    Write-Host 'Azure AD Module is already installed.'
} 
else 
{
    $in = Read-Host -Prompt "Azure AD is not installed and is required to run this script. Install module? `n[Y] Yes  [N] No"

    if ( $in -eq 'Y' -or $in -eq 'y' )
    {
        Write-Host 'Installing Azure AD module.'
        Install-Module -Name AzureAD
    }
    elseif ( $in -eq 'N' -or $in -eq 'n')
    {
        Write-Host 'Cancelling operation. Azure AD module is required to run this script.'
        return
    }
    else
    {
        Write-Host "Command not recognized. Exiting script."
    }
}

# convert password to secure string and login to AAD
$pass = ConvertTo-SecureString -String $Password -AsPlainText -Force
$AzureAdCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $pass
Connect-AzureAD -Credential $AzureAdCred

# login to PowerApps
Add-PowerAppsAccount -Username $Username -Password $pass

# branch to specific environment if provided, else search all environments
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
                if ($connDetails.apiDefinition.properties.isCustomApi)
                {
                    $creator = Get-AzureADUser -ObjectId $flowDetails.internal.properties.creator.objectId
                    $row = @{
                        AffectedResourceType = 'Flow'
                        DisplayName = $flowDetails.displayName
                        Name = $flowDetails.flowName
                        EnvironmentName = $flowDetails.environmentName
                        ConnectorDisplayName = $connDetails.displayName
                        ConnectionId = $connDetails.id
                        ConnectionName = $connDetails.connectionName
                        CreatedByObjectId = $creator.objectId
                        CreatedByUserPrincipalName = $creator.UserPrincipalName
                        IsCustomApiConnection = $connDetails.apiDefinition.properties.isCustomApi
                    }
                    $premiumFeatures += $(new-object psobject -Property $row)
                }
            }
        }        
    }
}

$premiumFeatures | Export-Csv -Path $Path