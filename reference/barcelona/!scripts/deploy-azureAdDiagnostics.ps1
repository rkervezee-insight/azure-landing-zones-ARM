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
$lawResourceId = "/subscriptions/8f8224ca-1a9c-46d1-9206-1cf2a7c51de8/resourcegroups/sjt-syd-cor-arg-management/providers/microsoft.operationalinsights/workspaces/sjt-syd-cor-law-c310db5e"

New-AzTenantDeployment -Name  "$($DeploymentName)-$($Location)" ` `
  -Location $Location `
  -TemplateFile ..\tenantTemplates\deploy-azureAdActivityLogs.json `
  -lawResourceId $lawResourceId  `
  -Verbose