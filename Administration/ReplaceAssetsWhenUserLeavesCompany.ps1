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
    .\UserLeftCompany.ps1 -Username "example@contoso.com" -Password "pass" -Leaver "meganb@bappartners.onmicrosoft.com" -Replacement "admin@bappartners.onmicrosoft.com" 
#>

param (
    [string]$Path = './appsAndFlowsWithNewOwners.csv',
    [Parameter(Mandatory=$true)]
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$Password,
    [Parameter(Mandatory=$true)]
    [string]$Leaver,
    [Parameter(Mandatory=$true)]
    [string]$Replacement
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

# login to AAD and PowerApps
$pass = ConvertTo-SecureString -String $Password -AsPlainText -Force
$AzureAdCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $pass
Connect-AzureAD -Credential $AzureAdCred
Add-PowerAppsAccount -Username $Username -Password $pass

Write-Progress -activity "Getting AAD User data" -status "Searching for users" -PercentComplete ((0/10) * 100)

# get leaver and replacement user object
$leaverObject = Get-AzureADUser -SearchString $Leaver
$replacementObject = Get-AzureADUser -SearchString $Replacement

$OutputObjectArray = @()
$environments = Get-AdminPowerAppEnvironment

# replace owner of apps currently owned by the leaver
Write-Progress -activity "Discovering and replacing PowerApps owned by leaver ... " -status "Searching for PowerApps." -PercentComplete ((1/10) * 100)
$apps = $environments | Get-AdminPowerApp -Owner $leaverObject.ObjectId
Write-Progress -activity "Discovering and replacing PowerApps owned by leaver ... " -status "Replacing ownership ." -PercentComplete ((2/10) * 100)

foreach($app in $apps)
{
    $appDetails = @{
        ResourceType = "PowerApp"
        EnvironmentName = $app.environmentName
        Name = $app.appName
        DisplayName = $app.displayName
        OwnerObjectId = $app.Owner.id
        OwnerDisplayName = $app.owner.displayName
        CreatedTime = $app.createdTime
        LastModifiedTime = $app.lastModifiedTime
    }
    $OutputObjectArray += $(new-object psobject -Property $appDetails)

    # replace owner
    $response = $app | Set-AdminPowerAppOwner -AppOwner $replacementObject.ObjectId
    #$response = $app | Set-AdminPowerAppOwner -AppOwner $leaverObject.ObjectId #test, reassign back to leaver
}

# add replacement user as owner of flows
Write-Progress -activity "Discovering and replacing Flows owned by leaver ... " -status "Searching for Flows." -PercentComplete ((3/10) * 100)
$flows = $environments | Get-AdminFlow -CreatedBy $leaverObject.ObjectId
Write-Progress -activity "Discovering and replacing Flows owned by leaver ... " -status "Adding replacement user as owner to Flows." -PercentComplete ((4/10) * 100)

foreach ($flow in $flows)
{
    # get leaver's owner role record
    $ownerRoles = $flow | Get-AdminFlowOwnerRole -Owner $leaverObject.ObjectId
    foreach ($ownerRole in $ownerRoles)
    {
        $flowDetails = @{
            ResourceType = "Flow"
            EnvironmentName = $flow.environmentName
            Name = $flow.flowName
            DisplayName = $flow.displayName
            OwnerObjectId = $flow.createdBy.ObjectId
            OwnerDisplayName = $leaverObject.displayName
            CreatedTime = $flow.createdTime
            LastModifiedTime = $flow.lastModifiedTime
        }
        #Write-Host $(new-object psobject -Property $flowDetails)
        $OutputObjectArray += $(new-object psobject -Property $flowDetails)

        # adds the replacement owner to the list of Flow owners
        $response = $flow | Set-AdminFlowOwnerRole -RoleName CanEdit -PrincipalType User -PrincipalObjectId $replacementObject.ObjectId
    }
}


# add replacement user as editor of shared connections
Write-Progress -activity "Discovering and replacing Shared Connections owned by leaver ... " -status "Searching for Connections." -PercentComplete ((5/10) * 100)
$connections = $environments | Get-AdminPowerAppConnection -CreatedBy $leaverObject.ObjectId
Write-Progress -activity "Discovering and replacing Shared Connections owned by leaver ... " -status "Adding replacement user as editor of shared connections." -PercentComplete ((6/10) * 100)

foreach ($connection in $connections)
{
    $connectorDefinition = $connection | Get-PowerAppConnector -ReturnConnectorSwagger

    if ($connectorDefinition.internal.properties.metadata.allowSharing -eq $true)
    {
        $connectionDetails = @{
            ResourceType = "Connection"
            EnvironmentName = $connection.environmentName
            Name = $connection.connectionName
            DisplayName = "[$($connectorDefinition.displayName)] $($connection.displayName)"
            OwnerObjectId = $connection.createdBy.id
            OwnerDisplayName = $leaverObject.displayName
            CreatedTime = $connection.createdTime
            LastModifiedTime = $connection.lastModifiedTime
        }

        #Write-Output $(new-object psobject -Property $connectionDetails)
        $OutputObjectArray += $(new-object psobject -Property $connectionDetails)
        
        # add replacement as connection owner
        $response = $connection | Set-AdminPowerAppConnectionRoleAssignment -RoleName 'CanEdit' -PrincipalType 'User' -PrincipalObjectId $replacementObject.ObjectId
    }
}

# add replacement user as editor of custom connectors
Write-Progress -activity "Discovering and replacing Custom Connectors owned by leaver ... " -status "Searching for Custom Connectors." -PercentComplete ((7/10) * 100)
$customConnectors = $environments | Get-AdminPowerAppConnector -CreatedBy $leaverObject.ObjectId
Write-Progress -activity "Discovering and replacing Custom Connectors owned by leaver ... " -status "Adding replacement user as editor of Custom Connectors." -PercentComplete ((8/10) * 100)

foreach ($connector in $customConnectors)
{
    $connectorDetails = @{
        ResourceType = "Custom Connector"
        EnvironmentName = $connector.environmentName
        Name = $connector.connectorName
        DisplayName = $connector.displayName
        OwnerObjectId = $connector.createdBy.id
        OwnerDisplayName = $connector.createdBy.displayName
        CreatedTime = $connector.createdTime
        LastModifiedTime = $connector.lastModifiedTime
    }
    #Write-Output $(new-object psobject -Property $connectorDetails)
    $OutputObjectArray += $(new-object psobject -Property $connectorDetails)

    $response = $connector | Set-AdminPowerAppConnectorRoleAssignment -RoleName 'CanEdit' -PrincipalType 'User' -PrincipalObjectId $replacementObject.ObjectId
}

Write-Progress -activity "Exporting data" -status "Generating CSV file and saving to $($OutputFilePath)" -PercentComplete ((9/10) * 100)

$OutputObjectArray | Export-Csv -Path $Path