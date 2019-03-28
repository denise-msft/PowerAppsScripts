# PowerApps and Flow PowerShell Scripts
Use PowerShell to automate ALM, Governance, and Administration activities on the Power Platform

### Notice
These scripts are experimental and not officialy supported by Microsoft. They are intended to fill certain gaps with the authoring experience of PowerApps and Flow administration. Use them at your own discretion and risk. Please understand of the intended behavior of the script provided in the README (documentation) before running the scripts.

## Install the PowerApps modules
See the documentation page [here](https://docs.microsoft.com/en-us/power-platform/admin/powerapps-powershell) for information on installation and requirements.

## Run the scripts
Once the modules are installed, follow these instructions to run the scripts provided below. If you receive a security warning, you may need to unblock running the downloaded script, see this article for more details.

1. Download the desired script.

2. Run PowerShell as an administrator and make sure you’re in the same directory as the script.

3. Run the script by typing out the name

        .\findFlowsWithHttpAction.ps1

4. Each of these scripts have optional parameters to specify behavior, such as the Environment (EnvironmentName) or the output file path name (Path). More details on each parameter is provided in the subfolder's documentation.

        .\findFlowsWithHttpAction.ps1 -EnvironmentName 820d6103-3f73-4107-a1b2-3449a98f5049 -Path ./myFlowsWithHttp.csv


## Sections
Based on the task, there are subfolders that hold multiple scripts to programmatically access the PowerApps and Flow APIs.

### [Reporting](./Reporting)
Use the reporting scripts to help discover a filtered list of PowerApps or Flows based on some features they leverage.

### [Administration](./Administration)   
Automated administrative tasks, such as updating permissions or cleaning up unauthorized resources.
