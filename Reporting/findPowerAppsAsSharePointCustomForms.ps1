param (
    # Provide the report path, note: report must end with .csv
    [string]$Path
)

# Decsription:
# PowerShell script to report on PowerApps created from SharePoint.
# Produces a report (.csv) 
# This script correlates to Item 21 on the PowerApps O365 DSE work.
#
# Date: 21st January 2019
# Author: Steve Jeffery (stjeffer@microsoft.com)

#Import-Module .\Microsoft.PowerApps.Administration.PowerShell.psm1
#Import-Module .\Microsoft.PowerApps.PowerShell.psm1

if (Test-Path $ReportPath) {
    Remove-Item $ReportPath
}
"App Name, CreatedTime, App Maker, App Location" | Out-File $ReportPath -Encoding ascii -Append

$collApps = Get-AdminPowerApp | Where-Object {$_.Internal.tags.primaryFormFactor -eq "Web"} |  Select-Object -ExpandProperty 'Internal' | Select-Object -ExpandProperty 'Properties' | Select-Object displayName, createdTime, lastModifiedTime, @{Name="createdBy"; Expression={$_.CreatedBy.email}}, @{Name="listUrl"; Expression={$_.embeddedApp.listUrl}}

foreach ($app in $collApps)
{
    $appName = $app.displayName
    $appCreated = $app.createdTime
    $appMaker = $app.createdBy
    $appLocation = $app.listUrl

    $appName + "," + $appCreated + "," + $appMaker + "," + $appLocation | Out-File $ReportPath -Append -Encoding ascii
}


