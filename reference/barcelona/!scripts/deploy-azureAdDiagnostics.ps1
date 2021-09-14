<#
.VERSION 1.0
.AUTHOR stephen.tulp@insight.com
.COMPANYNAME Insight

.RELEASENOTES
August 12, 2021 1.0   
    - Initial script

  .DESCRIPTION
    This script sends Azure AD Activity Logs to a Log Analytics workspace.
#>

# Parameters

$Location = "australiaeast"
$DeploymentName = "azureAdActivityLogs"
$lawResourceId = ""

New-AzTenantDeployment -Name  "$($DeploymentName)-$($Location)" ` `
  -Location $Location `
  -TemplateFile ..\tenantTemplates\deploy-azureAdActivityLogs.json `
  -lawResourceId $lawResourceId  `
  -Verbose