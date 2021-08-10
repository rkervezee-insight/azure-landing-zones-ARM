#
# Install module
#

Install-Module -Name Az

#
# Connect to Azure
#

Connect-AzAccount

#
# Create Service Principal and assign
# 'Owner' role to tenant root scope '/'
#

$servicePrincipal = New-AzADServicePrincipal -Role Owner -Scope / -DisplayName ADO-AzOps

#
# Display the generated Service Principal
#

Write-Host "ARM_TENANT_ID: $((Get-AzContext).Tenant.Id)"
Write-Host "ARM_SUBSCRIPTION_ID: $((Get-AzContext).Subscription.Id)"
Write-Host "ARM_CLIENT_ID: $($servicePrincipal.ApplicationId)"
Write-Host "ARM_CLIENT_SECRET: $($servicePrincipal.Secret | ConvertFrom-SecureString -AsPlainText)"