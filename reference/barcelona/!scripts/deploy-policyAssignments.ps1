<#
.VERSION 1.0
.AUTHOR stephen.tulp@insight.com
.COMPANYNAME Insight

.RELEASENOTES
August 12, 2021 1.0   
    - Initial script

  .DESCRIPTION
    This script deploys all the Azure Policy Assignments, use this if you want to only deploy this component only.
#>

# Parameters

$ESLZPrefix = "sjt"
$Location = "australiaeast"
$DeploymentName = "policyAssignments"


# Deploying Azure Assignments

New-AzManagementGroupDeployment -Name "$($ESLZPrefix)-$($DeploymentName)-azureGovernance-$($Location)" `
  -ManagementGroupId $ESLZPrefix `
  -topLevelManagementGroupPrefix $ESLZPrefix `
  -Location $Location `
  -TemplateFile ..\managementGroupTemplates\policyAssignments\apply-azureGovernancePolicyAssignment.json `
  -Verbose