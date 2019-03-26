# Reporting
Use these scripts to discover PowerApps and Flows based on features, such as the connectors used or if it uses a data gateway.

<br>

## PowerApps
Scripts to find PowerApps

### [PowerApps with Custom Connectors](./findPowerAppsWithCustomConnectors.ps1)

Lists connections to custom connectors being used in a PowerApp.
Input | Type | Description
---|---|---
Environment | string | Optional. The name (GUID) of the Environment. 
Path | string | Optional. The path and name for the output csv file.

### [PowerApps with Premium Connectors](./findPowerAppsWithCustomConnectors.ps1)
Lists connections to premium connectors being used in a PowerApp.
Input | Type | Description
---|---|---
Environment | string | Optional. The name (GUID) of the Environment. 
Path | string | Optional. The path and name for the output csv file.

### [PowerApps with on Prem Connectors using Data Gateway](./findPowerAppsWithCustomConnectors.ps1)
Lists connections to an On Premise gateway being used in a PowerApp.
Input | Type | Description
---|---|---
Environment | string | Optional. The name (GUID) of the Environment. 
Path | string | Optional. The path and name for the output csv file.


### [PowerApps used as SharePoint custom forms](./findPowerAppsWithCustomConnectors.ps1)
List PowerApps that are used as custom forms in the SharePoint List experience.
Input | Type | Description
---|---|---
Environment | string | Optional. The name (GUID) of the Environment. 
Path | string | Optional. The path and name for the output csv file.

<br>

---

## Flows
 
### [Flows with HTTP Actions](./findPowerAppsWithCustomConnectors.ps1)
Lists Flows that use the HTTP request action.
Input | Type | Description
---|---|---
Environment | string | Optional. The name (GUID) of the Environment. 
Path | string | Optional. The path and name for the output csv file.

### [Flows with Custom Connectors](./findPowerAppsWithCustomConnectors.ps1)
Lists connections to custom connectors being used in a Flow.
Input | Type | Description
---|---|---
**Username** | string | Required. The username of the admin account that will login to the AAD and PowerApps API services. 
**Password** | string | Required. 
Environment | string | Optional. The name (GUID) of the Environment. 
Path | string | Optional. The path and name for the output csv file. 

### [Flows using the previous version Common Data Service](./findFlowsWithCommonDataService1.ps1)
Lists connections to custom connectors being used in a Flow.
Input | Type | Description
---|---|---
Environment | string | Optional. The name (GUID) of the Environment. 
Path | string | Optional. The path and name for the output csv file.
