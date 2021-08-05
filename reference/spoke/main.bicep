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

@description('Specifies the storage prefix of the deployment.')
param staPrefix string = 'sta'

@description('Specifies the NSG prefix of the deployment.')
param nsgPrefix string = 'nsg'

@description('Specifies the Virtual Network prefix of the deployment.')
param vntPrefix string = 'vnt'

@description('Specifies the Route Table prefix of the deployment.')
param udrPrefix string = 'udr'

@description('Specifies the tags that you want to apply to all resources.')
param tags object = {}

// Landing Zone Network Resource parameters
@description('Specifies the address space of the vnet of the Landing Zone.')
param vnetAddressPrefix string

@description('Specifies the address space of the subnet that is used for web services in the Landing Zone.')
param webSubnetAddressPrefix string

@description('Specifies the address space of the subnet that is used for apps services in the Landing Zone.')
param appsSubnetAddressPrefix string

@description('Specifies the address space of the subnet that is used for data services in the Landing Zone.')
param dataSubnetAddressPrefix string

@description('Specifies the resource Id of the vnet in the Platform Connectivity Hub Subscription.')
param platformConnectivityVnetId string

@description('Specifies the IP address of the central firewall.')
param firewallPrivateIp string = '10.0.0.4'

@description('Specifies the IP addresses of the dns servers.')
param dnsServerAdresses array = []

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
var storageNamePrefix = toLower('${lzPrefix}${locPrefix}${envPrefix}${staPrefix}')
var rgPrefix = toLower('${lzPrefix}-${locPrefix}-${envPrefix}-${argPrefix}')
var tagsDefault = {
  applicationName: 'notset'
  owner: 'notset'
  businessCriticality: 'notset'
  ownerEmail: 'notset'
  costCenter: 'notset'
  dataClassification: 'notset'
}
var tagsJoined = union(tagsDefault, tags)

// Landing Zone Network resources
resource networkResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: '${rgPrefix}-network'
  location: location
  tags: tagsJoined
  properties: {}
}

module networkServices 'modules/network.bicep' = {
  name: 'networkServices'
  scope: networkResourceGroup
  params: {
    location: location
    tags: tagsJoined
    namePrefix: namePrefix
    nsgPrefix: nsgPrefix
    vntPrefix: vntPrefix
    udrPrefix: udrPrefix
    vnetAddressPrefix: vnetAddressPrefix
    firewallPrivateIp: firewallPrivateIp
    dnsServerAdresses: dnsServerAdresses
    webSubnetAddressPrefix: webSubnetAddressPrefix
    appsSubnetAddressPrefix: appsSubnetAddressPrefix
    dataSubnetAddressPrefix: dataSubnetAddressPrefix
    platformConnectivityVnetId: platformConnectivityVnetId
  }
}

resource networkWatcherResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: 'NetworkWatcherRG'
  location: location
  tags: tagsJoined
  properties: {}
}

module networkWatcher 'modules/networkWatcher.bicep' = {
  name: 'networkWatcher'
  scope: networkWatcherResourceGroup
  params: {
    location: location
    tags: tagsJoined
    name: ('networkWatcher-${location}')
  }
}

// Landing Zone Management resources
resource managementResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: '${rgPrefix}-management'
  location: location
  tags: tagsJoined
  properties: {}
}

module storageServices 'modules/storage.bicep' = {
  name: 'storageServices'
  scope: managementResourceGroup
  params: {
    location: location
    storageNamePrefix: storageNamePrefix
    tags: tagsJoined
  }
}

// Landing Zone Cost Management resources
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
