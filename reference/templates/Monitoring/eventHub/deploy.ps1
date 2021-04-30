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
$templateParameterFile = ".\parameters\azuredeploy.parameters.json"
$rg = "sjt-syd-cor-arg-monitoring"
$subId = "8f8224ca-1a9c-46d1-9206-1cf2a7c51de8"

# Select Subscription
Select-AzSubscription -subscriptionName $subId

# Test the deployment with "What If"
New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile

# Do the deployment
#New-AzResourceGroupDeployment -ResourceGroupName $rg -TemplateFile $templateFile -TemplateParameterFile $templateParameterFile