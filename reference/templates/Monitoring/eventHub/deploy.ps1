<#
.VERSION 1.0
.AUTHOR stephen.tulp@insight.com
.COMPANYNAME Insight

.RELEASENOTES
April 28, 2021 1.0   
    - Initial script

  .DESCRIPTION
    This template enables you to deploy an Azure Private DNS Zone
#>

# Parameters
$templateFile = ".\azuredeploy.json"
$rg = "rg-auea-pr-prd-splunkIntegration-01"
$subId = "1902a180-efa2-41dc-b943-b29398a3bb90"

# Select Subscription
Select-AzSubscription -subscriptionName $subId

# Test the deployment with "What If"
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile -WhatIf

# Do the deployment
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile