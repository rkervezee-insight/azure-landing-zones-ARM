@description('Name of the virtual machine.')
param vmName string = 'stig-vm'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v3'

@description('Username for the Virtual Machine.')
param adminUsername string

@minLength(12)
@description('Password for the Virtual Machine.')
@secure()
param adminPassword string

@allowed([
  '2019-Datacenter'
  '2016-Datacenter'
  '19h2-ent'
  '19h2-evd'
])
@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
param osVersion string = '2019-Datacenter'

@allowed([
  'Premium_LRS'
  'Standard_LRS'
  'StandardSSD_LRS'
])
@description('You can choose between Azure managed disks types to support your workload or scenario.')
param osDiskStorageType string = 'Premium_LRS'

@description('OS Disk Encryption Set resource id.')
param osDiskEncryptionSetResourceId string = ''

@description('Virtual Network for the VM Image.')
param vmVirtualNetwork string = 'stig-vm-vnet'

@description('Name of the resource group for the existing virtual network')
param virtualNetworkResourceGroupName string = resourceGroup().name

@description('Is the Virtual Network new or existing for the VM Image.')
param virtualNetworkNewOrExisting string = 'new'

@description('Address prefix of the virtual network')
param addressPrefix string = '10.0.0.0/16'

@description('Subnet name for the VM Image.')
param subnetName string = 'default'

@description('Subnet prefix of the virtual network')
param subnetPrefix string = '10.0.0.0/24'

@description('(Optional) Application Security Group resource id.')
param applicationSecurityGroupResourceId string = ''

@allowed([
  'default'
  'availabilitySet'
])
@description('(Optional) Availability options.')
param availabilityOptions string = 'default'

@description('(Optional) Availability set name.')
param availabilitySetName string = 'stig-vm-as'

@minValue(1)
@maxValue(5)
@description('(Optional) Instance count.')
param instanceCount int = 1

@minValue(1)
@maxValue(3)
@description('(Optional) Fault domains.')
param faultDomains int = 2

@minValue(1)
@maxValue(5)
@description('(Optional) Update domains.')
param updateDomains int = 3

@description('(Optional) Diagnostic Storage account resource id.')
param diagnosticStorageResourceId string = ''

@description('(Optional) Enable Azure Hybrid Benefit to use your on-premises Windows Server licenses and reduce cost. See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing for more information.')
param enableHybridBenefitServerLicense bool = true

var instanceCount_var = ((availabilityOptions == 'availabilitySet') ? instanceCount : 1)
var availabilitySet = {
  id: availabilitySetName_resource.id
}
var nicName = '${vmName}-nic'
var vnetId = {
  new: vmVirtualNetwork_resource.id
  existing: resourceId(virtualNetworkResourceGroupName, 'Microsoft.Storage/virtualNetworks', vmVirtualNetwork)
}
var subnetRef = '${vnetId[virtualNetworkNewOrExisting]}/subnets/${subnetName}'
var networkSecurityGroupName_var = '${vmName}-nsg'
var applicationSecurityGroup = [
  {
    id: applicationSecurityGroupResourceId
  }
]
var storageApiVersion = '2019-06-01'
var diskEncryptionSet = {
  id: osDiskEncryptionSetResourceId
}
var storageAccountResourceid = ((diagnosticStorageResourceId == '') ? 'fakestorageaccountresourceid' : diagnosticStorageResourceId)
var storageAccountName = ((diagnosticStorageResourceId == '') ? 'fakestorageaccountname' : split(diagnosticStorageResourceId, '/')[8])
var wadlogs = '<WadCfg> <DiagnosticMonitorConfiguration overallQuotaInMB="4096" xmlns="http://schemas.microsoft.com/ServiceHosting/2010/10/DiagnosticsConfiguration"> <DiagnosticInfrastructureLogs scheduledTransferLogLevelFilter="Error"/> <WindowsEventLog scheduledTransferPeriod="PT1M" > <DataSource name="Application!*[System[(Level = 1 or Level = 2)]]" /> <DataSource name="Security!*[System[(band(Keywords,13510798882111488))]]" /> <DataSource name="System!*[System[(Level = 1 or Level = 2)]]" /></WindowsEventLog>'
var wadperfcounters1 = '<PerformanceCounters scheduledTransferPeriod="PT1M"><PerformanceCounterConfiguration counterSpecifier="\\Processor(_Total)\\% Processor Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU utilization" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor(_Total)\\% Privileged Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU privileged time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor(_Total)\\% User Time" sampleRate="PT15S" unit="Percent"><annotation displayName="CPU user time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Processor Information(_Total)\\Processor Frequency" sampleRate="PT15S" unit="Count"><annotation displayName="CPU frequency" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\System\\Processes" sampleRate="PT15S" unit="Count"><annotation displayName="Processes" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Process(_Total)\\Thread Count" sampleRate="PT15S" unit="Count"><annotation displayName="Threads" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Process(_Total)\\Handle Count" sampleRate="PT15S" unit="Count"><annotation displayName="Handles" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\% Committed Bytes In Use" sampleRate="PT15S" unit="Percent"><annotation displayName="Memory usage" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\Available Bytes" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory available" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\Committed Bytes" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory committed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\Memory\\Commit Limit" sampleRate="PT15S" unit="Bytes"><annotation displayName="Memory commit limit" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\% Disk Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active time" locale="en-us"/></PerformanceCounterConfiguration>'
var wadperfcounters2 = '<PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\% Disk Read Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active read time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\% Disk Write Time" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk active write time" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Transfers/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Reads/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk read operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Writes/sec" sampleRate="PT15S" unit="CountPerSecond"><annotation displayName="Disk write operations" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Read Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk read speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\PhysicalDisk(_Total)\\Disk Write Bytes/sec" sampleRate="PT15S" unit="BytesPerSecond"><annotation displayName="Disk write speed" locale="en-us"/></PerformanceCounterConfiguration><PerformanceCounterConfiguration counterSpecifier="\\LogicalDisk(_Total)\\% Free Space" sampleRate="PT15S" unit="Percent"><annotation displayName="Disk free space (percentage)" locale="en-us"/></PerformanceCounterConfiguration></PerformanceCounters>'
var wadcfgxstart = '${wadlogs}${wadperfcounters1}${wadperfcounters2}<Metrics resourceId="'
var wadmetricsresourceid = resourceId('Microsoft.Compute/virtualMachines', vmName)
var wadcfgxend = '"><MetricAggregation scheduledTransferPeriod="PT1H"/><MetricAggregation scheduledTransferPeriod="PT1M"/></Metrics></DiagnosticMonitorConfiguration></WadCfg>'
var images = {
  '2019-Datacenter': {
    reference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-Datacenter'
      version: 'latest'
    }
  }
  '2016-Datacenter': {
    reference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2016-Datacenter'
      version: 'latest'
    }
  }
}

resource networkSecurityGroupName 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: networkSecurityGroupName_var
  location: location
  properties: {}
}

resource vmVirtualNetwork_resource 'Microsoft.Network/virtualNetworks@2020-06-01' = if (virtualNetworkNewOrExisting == 'new') {
  name: vmVirtualNetwork
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroupName.id
          }
        }
      }
    ]
  }
}

resource availabilitySetName_resource 'Microsoft.Compute/availabilitySets@2020-06-01' = if (availabilityOptions == 'availabilitySet') {
  name: availabilitySetName
  location: location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformUpdateDomainCount: updateDomains
    platformFaultDomainCount: faultDomains
  }
}

resource nicName_instanceCount_1 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0, instanceCount_var): {
  name: concat(nicName, ((instanceCount_var == 1) ? '' : i))
  location: location
  properties: {
    networkSecurityGroup: {
      id: networkSecurityGroupName.id
    }
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
          applicationSecurityGroups: ((applicationSecurityGroupResourceId == '') ? json('null') : applicationSecurityGroup)
        }
      }
    ]
  }
  dependsOn: [
    vmVirtualNetwork_resource
  ]
}]

resource nicName_instanceCount_1_Microsoft_Insights_service 'Microsoft.Network/networkInterfaces/providers/diagnosticSettings@2017-05-01-preview' = [for i in range(0, instanceCount_var): if ((!(diagnosticStorageResourceId == '')) {
  name: '${nicName}${((instanceCount_var == 1) ? '' : i)}/Microsoft.Insights/service'
  location: location
  properties: {
    storageAccountId: ((diagnosticStorageResourceId == '') ? json('null') : diagnosticStorageResourceId)
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
        }
      }
    ]
  }
  dependsOn: [
    nicName_instanceCount_1
  ]
}]

resource vmName_instanceCount_1 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0, instanceCount_var): {
  name: concat(vmName, ((instanceCount_var == 1) ? '' : i))
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: images[osVersion].reference
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskStorageType
          diskEncryptionSet: ((osDiskEncryptionSetResourceId == '') ? json('null') : diskEncryptionSet)
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', concat(nicName, ((instanceCount_var == 1) ? '' : i)))
        }
      ]
    }
    availabilitySet: ((availabilityOptions == 'availabilitySet') ? availabilitySet : json('null'))
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: ((diagnosticStorageResourceId == '') ? false() : true())
        storageUri: ((!(diagnosticStorageResourceId == '')) ? reference(diagnosticStorageResourceId, storageApiVersion).primaryEndpoints.blob : json('null'))
      }
    }
    licenseType: ((enableHybridBenefitServerLicense == true()) ? 'Windows_Server' : ((enableMultisessionClientLicense == true()) ? 'Windows_Client' : json('null')))
  }
  dependsOn: [
    nicName_instanceCount_1
  ]
}]

resource vmName_instanceCount_1_Microsoft_Insights_service 'Microsoft.Compute/virtualMachines/providers/diagnosticSettings@2017-05-01-preview' = [for i in range(0, instanceCount_var): if ((!(diagnosticStorageResourceId == '')) || (!(logAnalyticsWorkspaceId == ''))) {
  name: '${vmName}${((instanceCount_var == 1) ? '' : i)}/Microsoft.Insights/service'
  location: location
  properties: {
    storageAccountId: ((diagnosticStorageResourceId == '') ? json('null') : diagnosticStorageResourceId)
    workspaceId: ((logAnalyticsWorkspaceId == '') ? json('null') : logAnalyticsWorkspaceId)
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionInDays
        }
      }
    ]
  }
  dependsOn: [
    vmName_instanceCount_1
  ]
}]

resource vmName_instanceCount_1_Microsoft_EnterpriseCloud_Monitoring 'Microsoft.Compute/virtualMachines/extensions@2015-06-15' = [for i in range(0, instanceCount_var): if (!(logAnalyticsWorkspaceId == '')) {
  name: '${vmName}${((instanceCount_var == 1) ? '' : i)}/Microsoft.EnterpriseCloud.Monitoring'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: {
      workspaceId: ((logAnalyticsWorkspaceId == '') ? json('null') : reference(logAnalyticsWorkspaceId, '2015-03-20').customerId)
    }
    protectedSettings: {
      workspaceKey: ((logAnalyticsWorkspaceId == '') ? json('null') : listkeys(logAnalyticsWorkspaceId, '2015-03-20').primarySharedKey)
    }
  }
  dependsOn: [
    vmName_instanceCount_1_Microsoft_Insights_service
  ]
}]

resource vmName_instanceCount_1_Microsoft_Insights_VMDiagnosticsSettings 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, instanceCount_var): if (!(diagnosticStorageResourceId == '')) {
  name: '${vmName}${((instanceCount_var == 1) ? '' : i)}/Microsoft.Insights.VMDiagnosticsSettings'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Diagnostics'
    type: 'IaaSDiagnostics'
    typeHandlerVersion: '1.5'
    autoUpgradeMinorVersion: true
    settings: {
      xmlCfg: base64(concat(wadcfgxstart, wadmetricsresourceid, wadcfgxend))
      storageAccount: storageAccountName
    }
    protectedSettings: {
      storageAccountName: storageAccountName
      storageAccountKey: ((diagnosticStorageResourceId == '') ? '' : listkeys(storageAccountResourceid, '2019-06-01').keys[0].value)
      storageAccountEndPoint: 'https://${environment().suffixes.storage}'
    }
  }
  dependsOn: [
    vmName_instanceCount_1_Microsoft_EnterpriseCloud_Monitoring
  ]
}]

resource vmName_instanceCount_1_install_powershell_modules 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for i in range(0, instanceCount_var): if (!(artifactsLocation == '')) {
  name: '${vmName}${((instanceCount_var == 1) ? '' : i)}/install-powershell-modules'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      fileUris: [
        concat(artifactsLocation, requiredModulesFile, artifactsLocationSasToken_var)
        concat(artifactsLocation, installPSModulesFile, artifactsLocationSasToken_var)
        concat(artifactsLocation, generateStigChecklist, artifactsLocationSasToken_var)
      ]
      ignoreRelativePathForFileDownloads: true
    }
    settings: {
      timestamp: 123456788
      commandToExecute: 'PowerShell -ExecutionPolicy Unrestricted -File ${installPSModulesFile} -autoInstallDependencies ${autoInstallDependencies}'
    }
  }
  dependsOn: [
    vmName_instanceCount_1_Microsoft_Insights_VMDiagnosticsSettings
  ]
}]

resource vmName_instanceCount_1_setup_win_dsc_stig 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = [for i in range(0, instanceCount_var): if (!(artifactsLocation == '')) {
  name: '${vmName}${((instanceCount_var == 1) ? '' : i)}/setup-win-dsc-stig'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.77'
    autoUpgradeMinorVersion: true
    settings: {
      wmfVersion: 'latest'
      configuration: {
        url: '${artifactsLocation}Windows.ps1.zip${artifactsLocationSasToken_var}'
        script: 'Windows.ps1'
        function: 'Windows'
      }
    }
  }
  dependsOn: [
    vmName_instanceCount_1_install_powershell_modules
  ]
}]

module pid_93aca1dd_7b6a_4db4_a130_45f5b7c82c5c './nested_pid_93aca1dd_7b6a_4db4_a130_45f5b7c82c5c.bicep' = {
  name: 'pid-93aca1dd-7b6a-4db4-a130-45f5b7c82c5c'
  params: {}
}
