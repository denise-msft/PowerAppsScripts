[CmdletBinding(DefaultParameterSetName="Report")]
param (
    # Will only report on unauthorised environments
    [Parameter(ParameterSetName="Report")]
    [switch]$ReportOnly,
    # Provide the report path, note: report must end with .csv
    [Parameter(ParameterSetName="Report")]
    [string]$ReportPath,
    # List of approved environments
    [Parameter(ParameterSetName="Report")]
    [array]$ApprovedEnvironments,
    # Will run the script in removal mode
    [Parameter(ParameterSetName="Remove")]
    [switch]$RemoveUnauthorisedEnvironment,
    # You can provide an array of environments, note, this must be the environment GUID ('name' field)
    [Parameter(ParameterSetName="Remove")]
    [array]$EnvironmentGuid
)

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

if ( $ReportOnly )
{
    if ( Test-Path $ReportPath )
	{
        Remove-Item $ReportPath
    }

    "DisplayName, EnvironmentName, CreatedTime, CreatedBy" | Out-File $ReportPath -Encoding ascii -Append

    $allEnvironments = Get-AdminEnvironment
    foreach ( $env in $allEnvironments )
	{
        if( $ApprovedEnvironments -notcontains $env.DisplayName )
		{
            $env.DisplayName + "," + $env.EnvironmentName + "," + $env.CreatedTime + "," + $env.CreatedBy.email | Out-File $ReportPath -Encoding ascii -Append
        }
    }
}

if ( $RemoveUnauthorisedEnvironment )
{
    foreach( $unauthorisedEnvironment in $EnvironmentGuid )
    {
        Remove-AdminEnvironment -EnvironmentName $unauthorisedEnvironment        
    }
}
