<#
.VERSION 1.0
.AUTHOR stephen.tulp@insight.com
.COMPANYNAME Insight

.RELEASENOTES
August 12, 2021 1.0   
    - Initial script

  .DESCRIPTION
    This script moves the Platorm Management Subscription to the appropriate Management Group, use this if you want to only deploy this component only.
#>

# Parameters

$ESLZPrefix = "sjt"
$Location = "australiaeast"
$DeploymentName = "movePlatformManagementSub"
$ManagementSubscriptionId = "5cb7efe0-67af-4723-ab35-0f2b42a85839"

New-AzManagementGroupDeployment -Name "$($ESLZPrefix)-$($DeploymentName)-$($Location)" `
    -ManagementGroupId $ESLZPrefix `
    -Location $Location `
    -TemplateFile ..\managementGroupTemplates\subscriptionOrganization\subscriptionOrganization.json `
    -targetManagementGroupId "$($ESLZPrefix)-management" `
    -subscriptionId $ManagementSubscriptionId  `
    -Verbose