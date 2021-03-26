<#
.VERSION 1.0
.AUTHOR stephen.tulp@insight.com
.COMPANYNAME Insight

.RELEASENOTES
February, 2021 1.0   
    - Initial script

  .DESCRIPTION
    This script cleans an Azure Subscription and removes all blueprints, Azure Policy, RBAC permissions and resource groups. Please only run this in a MSDN or test environment.
#>

# Subscriptions
$subcriptionId = "afa561b9-1bcc-4e69-bb33-af606363a7df" # Insight-IT-Management
#$subcriptionId = "8f8224ca-1a9c-46d1-9206-1cf2a7c51de8" # Insight-IT-Connectivity
#$subcriptionId = "5cb7efe0-67af-4723-ab35-0f2b42a85839" # Insight-IT-Identity


# Switch to selected subscription
Set-AzContext -SubscriptionId $subcriptionId

# Remove all Azure blueprint assignments
$bps = Get-AzBlueprintAssignment -SubscriptionId $subcriptionId
foreach ($bp in $bps) {
    $temp = "Deleting blueprint assignment {0}" -f $bp.Name
    Write-Host $temp
    Remove-AzBlueprintAssignment -Name $bp.Name
}

# todo - bust cache if locks were used
# get a new auth token

# loop through each rg in a sub
$rgs = Get-AzResourceGroup
foreach ($rg in $rgs) {
    $temp = "Deleting {0}..." -f $rg.ResourceGroupName
    Write-Host $temp
    Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force # delete the current rg
    # some output on a good result
}

# loop through policies
$policies = Get-AzPolicyAssignment
foreach ($policy in $policies) {
    $temp = "Removing policy assignment: {0}" -f $policy.Name
    Write-Host $temp
    Remove-AzPolicyAssignment -ResourceId $policy.ResourceId # TODO - also print display name..
}

# get-azroleassignment returns assignments at current OR parent scope`
# will need to do a check on the scope property
# todo - not entirely sure how well this is working...
$rbacs = Get-AzRoleAssignment 
foreach ($rbac in $rbacs) {
    if ($rbac.Scope -eq "/subscriptions/$subscriptionId") { # extra logic to make sure we are only removing role assignments at the target sub
        Write-Output "Found a role assignment to delete"
        Remove-AzRoleAssignment -InputObject $rbac
    } else {
        $temp = "NOT deleting role with scope {0}" -f $rbac.Scope
    }
}