targetScope = 'resourceGroup'

// Parameters
param platformConnectivityVnetId string
param landingZoneVnetId string

// Variables
var platformConnectivityVnetName = length(split(platformConnectivityVnetId, '/')) >= 9 ? last(split(platformConnectivityVnetId, '/')) : 'incorrectSegmentLength'
var landingZoneVnetName = length(split(landingZoneVnetId, '/')) >= 9 ? last(split(landingZoneVnetId, '/')) : 'incorrectSegmentLength'

// Resources
resource hubToSpokeVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  name: '${platformConnectivityVnetName}/${platformConnectivityVnetName}-to-${landingZoneVnetName}'
  properties: {
    allowForwardedTraffic: true
    allowGatewayTransit: true
    allowVirtualNetworkAccess: true
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: landingZoneVnetId
    }
    useRemoteGateways: false
  }
}

// Outputs
