targetScope = 'subscription'

// Landing Zone parameters
@minLength(2)
@maxLength(5)
@description('Specifies the Landing Zone prefix for all resources created in this deployment.')
param lzPrefix string

@description('Specifies the location for all resources.')
param location string

@allowed([
  'dev'
  'tst'
  'prd'
])
@description('Specifies the environment of the deployment.')
param envPrefix string

@description('Specifies the resource group prefix of the deployment.')
param argPrefix string = 'arg'

@description('Specifies the NSG prefix of the deployment.')
param nsgPrefix string = 'nsg'

@description('Specifies the Virtual Network prefix of the deployment.')
param vntPrefix string = 'vnt'

@description('Specifies the Route Table prefix of the deployment.')
param udrPrefix string = 'udr'

@description('Specifies the Key Vault prefix of the deployment.')
param akvPrefix string = 'akv'

@description('Specifies the Recovery Vault prefix of the deployment.')
param rsvPrefix string = 'rsv'

@description('Specifies the tags that you want to apply to all resources.')
param tags object = {}

@description('Specifies the address space of the vnet of the Landing Zone.')
param network array = []

@description('Specifies the IP addresses of the dns servers.')
param dnsServerAddresses array = []

// Landing Zone Cost Management parameters
@description('Specifies the budget amount for the Landing Zone.')
param amount int

@description('Specifies the budget timeperiod for the Landing Zone.')
param timeGrain string

@description('Specifies the budget first theshold % (0-100) for the Landing Zone.')
param firstThreshold int

@description('Specifies the budget second theshold % (0-100) for the Landing Zone.')
param secondThreshold int

@description('Specifies an array of email addresses for the Azure budget.')
param contactEmails array

@description('Specifies an array of Azure Roles (Owner, Contributor) for the Azure budget.')
param contactRoles array

// Variables
var locPrefix = replace(location, 'australiaeast', 'syd')
var namePrefix = toLower('${lzPrefix}-${locPrefix}-${envPrefix}')
var rgPrefix = toLower('${namePrefix}-${argPrefix}')
var tagsDefault = {
  applicationName: 'notset'
  owner: 'notset'
  businessCriticality: 'notset'
  ownerEmail: 'notset'
  costCenter: 'notset'
  dataClassification: 'notset'
}
var tagsJoined = union(tagsDefault, tags)

// Landing Zone Network Resource Group
resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: '${rgPrefix}-network'
  location: location
  tags: tagsJoined
  properties: {}
}

// Landing Zone Network Resources
module networkServices 'modules/network.bicep' = [for (nw, index) in network: {
  name: 'networkServices-${index}'
  scope: networkResourceGroup
  params: {
    location: location
    tags: tagsJoined
    namePrefix: namePrefix
    nsgPrefix: nsgPrefix
    vntPrefix: vntPrefix
    udrPrefix: udrPrefix
    vnetAddressPrefix: nw.vnetAddressPrefix
    firewallPrivateIp: nw.firewallPrivateIp
    dnsServerAddresses: dnsServerAddresses
    subnetArray: nw.subnetArray
    hubVnetId: nw.hubVnetId
  }
}]

// Landing Zone Network Watcher Resource Group
resource networkWatcherResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'NetworkWatcherRG'
  location: location
  tags: tagsJoined
  properties: {}
}

// Landing Zone Network Watcher Resources
module networkWatcher 'modules/networkWatcher.bicep' = {
  name: 'networkWatcher'
  scope: networkWatcherResourceGroup
  params: {
    location: location
    tags: tagsJoined
    name: ('networkWatcher-${location}')
  }
}

// Landing Zone Management Resource Group
resource managementResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: '${rgPrefix}-management'
  location: location
  tags: tagsJoined
  properties: {}
}

// Landing Zone Diagnostics Storage Account
module storageServices 'modules/storage.bicep' = {
  name: 'storageServices'
  scope: managementResourceGroup
  params: {
    location: location
    storagePrefix: lzPrefix
    tags: tagsJoined
  }
}

// Landing Zone Azure Key Vault
module keyVaultServices 'modules/keyvault.bicep' = {
  name: 'keyVaultServices'
  scope: managementResourceGroup
  params: {
    location: location
    namePrefix: namePrefix
    akvPrefix: akvPrefix
    tags: tagsJoined
  }
}

// Landing Zone Recovery Services Vault
module recoveryVaultServices 'modules/recoveryVault.bicep' = {
  name: 'recoveryVaultServices'
  scope: managementResourceGroup
  params: {
    location: location
    namePrefix: namePrefix
    rsvPrefix: rsvPrefix
    tags: tagsJoined
  }
}

// Landing Zone Azure Budget
module budgets 'modules/budgets.bicep' = {
  name: 'budgets'
  scope: subscription()
  params: {
    amount: amount
    timeGrain: timeGrain
    firstThreshold: firstThreshold
    secondThreshold: secondThreshold
    contactEmails: contactEmails
    contactRoles: contactRoles
  }
}

// Outputs
output managementResourceGroup string = managementResourceGroup.name
output networkWatcherResourceGroup string = networkWatcherResourceGroup.name
output networkResourceGroup string = networkResourceGroup.name
output tags object = tags
