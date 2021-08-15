<#
.VERSION 1.0
.AUTHOR stephen.tulp@insight.com
.COMPANYNAME Insight

.RELEASENOTES
August 12, 2021 1.0   
    - Initial script

  .DESCRIPTION
    This script deploys the Management Group structure for Enterprise-Scale, use this if you want to only deploy this component only.
#>

# Parameters

$ESLZPrefix = "sjt"
$Location = "australiaeast"
$DeploymentName = "mgStructure"
$TenantRootGroupId = (Get-AzTenant).Id

New-AzManagementGroupDeployment -Name  "$($ESLZPrefix)-$($DeploymentName)-$($Location)" ` `
  -ManagementGroupId $TenantRootGroupId `
  -Location $Location `
  -TemplateFile ..\managementGroupTemplates\mgmtGroupStructure\mgmtGroups.json `
  -topLevelManagementGroupPrefix $ESLZPrefix `
  -Verbose