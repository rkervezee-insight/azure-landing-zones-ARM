<#
.VERSION 1.0
.AUTHOR stephen.tulp@insight.com
.COMPANYNAME Insight

.RELEASENOTES
April 28, 2021 1.0   
    - Initial script

  .DESCRIPTION
    This template enables you to deploy a EventHubs Standard namespace, an Event Hub, a consumer group and authorizationRules
#>

# Parameters
$templateFile = ".\azuredeploy.json"
$templateParametersFile = ".\parameters\azuredeploy.parameters.json"
$rg = "rg-auea-pr-prd-paasdns-01"
$subId = "4dbf040a-1431-4a27-a586-99cd795a9b44"

# Select Subscription
Select-AzSubscription -subscriptionName $subId

# Test the deployment with "What If"
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $templateFile -templateParametersFile $templateParametersFile -WhatIf

# Do the deployment
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $templateFile -templateParametersFile $templateParametersFile