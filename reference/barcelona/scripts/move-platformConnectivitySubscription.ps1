<#
.VERSION 1.0
.AUTHOR stephen.tulp@insight.com
.COMPANYNAME Insight

.RELEASENOTES
August 12, 2021 1.0   
    - Initial script

  .DESCRIPTION
    This script moves the Platorm Connectivity Subscription to the appropriate Management Group, use this if you want to only deploy this component only.
#>

# Parameters

$ESLZPrefix = "sjt"
$Location = "australiaeast"
$DeploymentName = "movePlatformConnectivitySub"
$ConnectivitySubscriptionId = "8d0248a2-d875-4407-99a6-0981fe09bff2"

New-AzManagementGroupDeployment -Name "$($ESLZPrefix)-$($DeploymentName)-$($Location)" `
  -ManagementGroupId $ESLZPrefix `
  -Location $Location `
  -TemplateFile ..\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
  -targetManagementGroupId "$($ESLZPrefix)-connectivity" `
  -subscriptionId $ConnectivitySubscriptionId   `
  -Verbose