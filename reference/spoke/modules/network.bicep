targetScope = 'resourceGroup'

// Landing Zone Network Parameters

@description('Specifies the location for all resources.')
param location string

@description('Specifies the naming prefix.')
param namePrefix string

@description('Specifies the tags that you want to apply to all resources.')
param tags object

@description('Specifies the NSG prefix of the deployment.')
param nsgPrefix string

@description('Specifies the Virtual Network prefix of the deployment.')
param vntPrefix string

@description('Specifies the Route Table prefix of the deployment.')
param udrPrefix string

@description('Specifies the IP address of the central firewall.')
param firewallPrivateIp string

@description('Specifies the IP addresses of the dns servers.')
param dnsServerAdresses array

@description('Specifies the resource Id of the vnet in the Platform Connectivity Hub Subscription.')
param platformConnectivityVnetId string

@description('Specifies the address space of the vnet of the Landing Zone.')
param vnetAddressPrefix string

@description('Specifies the address space of the subnet that is used for web services in the Landing Zone.')
param webSubnetAddressPrefix string

@description('Specifies the address space of the subnet that is used for apps services in the Landing Zone.')
param appsSubnetAddressPrefix string

@description('Specifies the address space of the subnet that is used for data services in the Landing Zone.')
param dataSubnetAddressPrefix string

@allowed([
  'Yes'
  'No'
])
@description('Optional. Boolean for Resource Lock.')
param resourceLock string = 'Yes'

// Variables
var vnetAddressSpace = substring(vnetAddressPrefix, 0, (length(vnetAddressPrefix) - 3))
var webSubnetName = 'web'
var appsSubnetName = 'apps'
var dataSubnetName = 'data'
var routeTableName = take('${namePrefix}-${udrPrefix}-${guid(namePrefix)}', 24)
var platformConnectivityVnetSubscriptionId = length(split(platformConnectivityVnetId, '/')) >= 9 ? split(platformConnectivityVnetId, '/')[2] : subscription().subscriptionId
var platformConnectivityVnetResourceGroupName = length(split(platformConnectivityVnetId, '/')) >= 9 ? split(platformConnectivityVnetId, '/')[4] : resourceGroup().name
var platformConnectivityVnetName = length(split(platformConnectivityVnetId, '/')) >= 9 ? last(split(platformConnectivityVnetId, '/')) : 'incorrectSegmentLength'

// Creation of the Azure Route Table for the Landing Zone
resource routeTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: routeTableName
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'subnet-to-connectivityHub'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewallPrivateIp
        }
      }
    ]
  }
}

// Creation of the Network Security Group for the Landing Zone
resource webNsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: ('${namePrefix}-${nsgPrefix}-${webSubnetName}')
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

resource appsNsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: ('${namePrefix}-${nsgPrefix}-${appsSubnetName}')
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

resource dataNsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: ('${namePrefix}-${nsgPrefix}-${dataSubnetName}')
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// Creation of Azure Virtual Networking for the Landing Zone
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: ('${namePrefix}-${vntPrefix}-${vnetAddressSpace}')
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: dnsServerAdresses
    }

    enableDdosProtection: false
    subnets: [
      {
        name: webSubnetName
        properties: {
          addressPrefix: webSubnetAddressPrefix
          addressPrefixes: []
          networkSecurityGroup: {
            id: webNsg.id
          }
          routeTable: {
            id: routeTable.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          serviceEndpointPolicies: []
          serviceEndpoints: []
        }
      }
      {
        name: appsSubnetName
        properties: {
          addressPrefix: appsSubnetAddressPrefix
          addressPrefixes: []
          networkSecurityGroup: {
            id: appsNsg.id
          }
          routeTable: {
            id: routeTable.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          serviceEndpointPolicies: []
          serviceEndpoints: []
        }
      }
      {
        name: dataSubnetName
        properties: {
          addressPrefix: dataSubnetAddressPrefix
          addressPrefixes: []
          networkSecurityGroup: {
            id: dataNsg.id
          }
          routeTable: {
            id: routeTable.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          serviceEndpointPolicies: []
          serviceEndpoints: []
        }
      }
    ]
  }
}

resource spokeToHubVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = if (!empty(platformConnectivityVnetId)) {
  name: '${vnet.name}/FROM-${vnet.name}-TO-${platformConnectivityVnetName}'
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    allowVirtualNetworkAccess: true
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: platformConnectivityVnetId
    }
    useRemoteGateways: false
  }
}

module hubToSpokeVnetPeering 'auxiliary/vnetPeering.bicep' = if (!empty(platformConnectivityVnetId)) {
  name: 'FROM-${platformConnectivityVnetName}-TO-${vnet.name}'
  scope: resourceGroup(platformConnectivityVnetSubscriptionId, platformConnectivityVnetResourceGroupName)
  params: {
    landingZoneVnetId: vnet.id
    platformConnectivityVnetId: platformConnectivityVnetId
  }
}

resource lockResource 'Microsoft.Authorization/locks@2016-09-01' = if (!empty(resourceLock)) {
  name: '${vnet.name}-DontDelete'
  scope: vnet
  dependsOn: [
    vnet
  ]
  properties: {
    level: 'CanNotDelete'
  }
}

// Outputs
output vNetResourceGroup string = resourceGroup().name
output vNetName string = vnet.name
output vNetResourceId string = vnet.id
