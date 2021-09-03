<#
.VERSION 1.0
.AUTHOR stephen.tulp@insight.com
.COMPANYNAME Insight

.RELEASENOTES
August 12, 2021 1.0   
    - Initial script

  .DESCRIPTION
    This script deploys Azure AD Activity Logs to Log Analytics, use this if you want to only deploy this component only.
#>

# Parameters

$Location = "australiaeast"
$DeploymentName = "azureAdActivityLogs"

New-AzTenantDeployment -Name  "$($DeploymentName)-$($Location)" ` `
  -Location $Location `
  -TemplateFile ..\managementGroupTemplates\tenant.json `
  -Verbose