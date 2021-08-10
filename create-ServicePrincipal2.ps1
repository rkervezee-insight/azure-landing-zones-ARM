#
# Install module
#

Install-Module -Name AzureAD

#
# Connect to Azure Active Directory
#

Connect-AzureAD

#
# Get Service Principal from Azure AD
#

$servicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq 'AzOps'"

#
# Assign Azure AD Directory Role
#

$directoryRole = Get-AzureADDirectoryRole -Filter "DisplayName eq 'Directory Readers'"
if ($directoryRole -eq $null) {
    Write-Warning "Directory Reader role not found"
}
else {
    Add-AzureADDirectoryRoleMember -ObjectId $directoryRole.ObjectId -RefObjectId $servicePrincipal.ObjectId
}