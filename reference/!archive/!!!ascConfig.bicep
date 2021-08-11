targetScope = 'subscription'

@metadata({
  displayName: 'Security contacts email address'
  description: 'Provide email address for Azure Security Center contact details'
})
param emailSecurityContact string

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for Virtual Machines'
  description: 'Azure Defender pricing tier for Virtual Machines'
})
param pricingTierVMs string = 'Standard'

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for SQL Servers'
  description: 'Azure Defender pricing tier for SQL Servers'
})
param pricingTierSqlServers string = 'Standard'

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for App Services'
  description: 'Azure Defender pricing tier for App Services'
})
param pricingTierAppServices string = 'Standard'

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for Storage Accounts'
  description: 'Azure Defender pricing tier for Storage Accounts'
})
param pricingTierStorageAccounts string = 'Standard'

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for SQL Server Virtual Machines'
  description: 'Azure Defender pricing tier for SQL Server Virtual Machines'
})
param pricingTierSqlServerVirtualMachines string = 'Standard'

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for AKS'
  description: 'Azure Defender pricing tier for AKS'
})
param pricingTierKubernetesService string = 'Standard'

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for ACR'
  description: 'Azure Defender pricing tier for ACR'
})
param pricingTierContainerRegistry string = 'Standard'

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for AKV'
  description: 'Azure Defender pricing tier for AKV'
})
param pricingTierKeyVaults string = 'Standard'

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for DNS'
  description: 'Azure Defender pricing tier for DNS'
})
param pricingTierDns string = 'Standard'

@allowed([
  'Standard'
  'Free'
])
@metadata({
  displayName: 'Azure Defender pricing tier for Azure Resource Manager'
  description: 'Azure Defender pricing tier for Azure Resource Manager'
})
param pricingTierArm string = 'Standard'

@minLength(2)
@maxLength(5)
@description('Specifies the Landing Zone prefix for all resources created in this deployment.')
param lzPrefix string

@metadata({
  displayName: 'Log Analytics workspace'
  description: 'The Log Analytics workspace of where the data should be exported to.'
  strongType: 'Microsoft.OperationalInsights/workspaces'
  assignPermissions: true
})
param workspaceResourceId string
param guidValue string = newGuid()

@description('Specifies the location for all resources.')
param location string

@description('Specifies the tags that you want to apply to all resources.')
param tags object

var resourceGroupName = '${lzPrefix}-asc-export'
var exportedDataTypes = [
  'Security recommendations'
  'Security alerts'
  'Overall secure score'
  'Secure score controls'
  'Regulatory compliance'
  'Overall secure score - snapshot'
  'Secure score controls - snapshot'
  'Regulatory compliance - snapshot'
]
var isSecurityFindingsEnabled = true
var recommendationNames = []
var recommendationSeverities = [
  'High'
  'Medium'
  'Low'
]
var alertSeverities = [
  'High'
  'Medium'
  'Low'
]
var secureScoreControlsNames = []
var regulatoryComplianceStandardsNames = []
var scopeDescription = 'scope for subscription {0}'
var subAssessmentRuleExpectedValue = '/assessments/{0}/'
var recommendationNamesLength = length(recommendationNames)
var secureScoreControlsNamesLength = length(secureScoreControlsNames)
var secureScoreControlsLengthIfEmpty = ((secureScoreControlsNamesLength == 0) ? 1 : secureScoreControlsNamesLength)
var regulatoryComplianceStandardsNamesLength = length(regulatoryComplianceStandardsNames)
var regulatoryComplianceStandardsNamesLengthIfEmpty = ((regulatoryComplianceStandardsNamesLength == 0) ? 1 : regulatoryComplianceStandardsNamesLength)
var recommendationSeveritiesLength = length(recommendationSeverities)
var alertSeveritiesLength = length(alertSeverities)
var recommendationNamesLengthIfEmpty = ((recommendationNamesLength == 0) ? 1 : recommendationNamesLength)
var recommendationSeveritiesLengthIfEmpty = ((recommendationSeveritiesLength == 0) ? 1 : recommendationSeveritiesLength)
var alertSeveritiesLengthIfEmpty = ((alertSeveritiesLength == 0) ? 1 : alertSeveritiesLength)
var totalRuleCombinationsForOneRecommendationName = recommendationSeveritiesLengthIfEmpty
var totalRuleCombinationsForOneRecommendationSeverity = 1
var exportedDataTypesLength = length(exportedDataTypes)
var exportedDataTypesLengthIfEmpty = ((exportedDataTypesLength == 0) ? 1 : exportedDataTypesLength)
var dataTypeMap = {
  'Security recommendations': 'Assessments'
  'Security alerts': 'Alerts'
  'Overall secure score': 'SecureScores'
  'Secure score controls': 'SecureScoreControls'
  'Regulatory compliance': 'RegulatoryComplianceAssessment'
  'Overall secure score - snapshot': 'SecureScoresSnapshot'
  'Secure score controls - snapshot': 'SecureScoreControlsSnapshot'
  'Regulatory compliance - snapshot': 'RegulatoryComplianceAssessmentSnapshot'
}
var alertSeverityMap = {
  High: 'high'
  Medium: 'medium'
  Low: 'low'
}
var ruleSetsForAssessmentsObj = {
  ruleSetsForAssessmentsArr: [for j in range(0, (recommendationNamesLengthIfEmpty * recommendationSeveritiesLengthIfEmpty)): {
    rules: [
      {
        propertyJPath: ((recommendationNamesLength == 0) ? 'type' : 'name')
        propertyType: 'string'
        expectedValue: ((recommendationNamesLength == 0) ? 'Microsoft.Security/assessments' : recommendationNames[((j / totalRuleCombinationsForOneRecommendationName) % recommendationNamesLength)])
        operator: 'Contains'
      }
      {
        propertyJPath: 'properties.metadata.severity'
        propertyType: 'string'
        expectedValue: recommendationSeverities[((j / totalRuleCombinationsForOneRecommendationSeverity) % recommendationSeveritiesLength)]
        operator: 'Equals'
      }
    ]
  }]
}
var customRuleSetsForSubAssessmentsObj = {
  ruleSetsForSubAssessmentsArr: [for j in range(0, recommendationNamesLengthIfEmpty): {
    rules: [
      {
        propertyJPath: 'id'
        propertyType: 'string'
        expectedValue: ((recommendationNamesLength == 0) ? json('null') : replace(subAssessmentRuleExpectedValue, '{0}', recommendationNames[j]))
        operator: 'Contains'
      }
    ]
  }]
}
var ruleSetsForAlertsObj = {
  ruleSetsForAlertsArr: [for j in range(0, alertSeveritiesLengthIfEmpty): {
    rules: [
      {
        propertyJPath: 'Severity'
        propertyType: 'string'
        expectedValue: alertSeverityMap[alertSeverities[(j % alertSeveritiesLengthIfEmpty)]]
        operator: 'Equals'
      }
    ]
  }]
}
var customRuleSetsForSecureScoreControlsObj = {
  ruleSetsForSecureScoreControlsArr: [for j in range(0, secureScoreControlsLengthIfEmpty): {
    rules: [
      {
        propertyJPath: 'name'
        propertyType: 'string'
        expectedValue: ((secureScoreControlsNamesLength == 0) ? json('null') : secureScoreControlsNames[j])
        operator: 'Equals'
      }
    ]
  }]
}
var customRuleSetsForRegulatoryComplianceObj = {
  ruleSetsForRegulatoryCompliancArr: [for i in range(0, regulatoryComplianceStandardsNamesLengthIfEmpty): {
    rules: [
      {
        propertyJPath: 'id'
        propertyType: 'string'
        expectedValue: ((regulatoryComplianceStandardsNamesLength == 0) ? json('null') : regulatoryComplianceStandardsNames[i])
        operator: 'Contains'
      }
    ]
  }]
}
var ruleSetsForSecureScoreControlsObj = ((secureScoreControlsNamesLength == 0) ? json('null') : customRuleSetsForSecureScoreControlsObj.ruleSetsForSecureScoreControlsArr)
var ruleSetsForSecureRegulatoryComplianceObj = ((regulatoryComplianceStandardsNamesLength == 0) ? json('null') : customRuleSetsForRegulatoryComplianceObj.ruleSetsForRegulatoryCompliancArr)
var ruleSetsForSubAssessmentsObj = ((recommendationNamesLength == 0) ? json('null') : customRuleSetsForSubAssessmentsObj.ruleSetsForSubAssessmentsArr)
var subAssessmentSource = [
  {
    eventSource: 'SubAssessments'
    ruleSets: ruleSetsForSubAssessmentsObj
  }
]
var ruleSetsMap = {
  'Security recommendations': ruleSetsForAssessmentsObj.ruleSetsForAssessmentsArr
  'Security alerts': ruleSetsForAlertsObj.ruleSetsForAlertsArr
  'Overall secure score': null
  'Secure score controls': ruleSetsForSecureScoreControlsObj
  'Regulatory compliance': ruleSetsForSecureRegulatoryComplianceObj
  'Overall secure score - snapshot': null
  'Secure score controls - snapshot': ruleSetsForSecureScoreControlsObj
  'Regulatory compliance - snapshot': ruleSetsForSecureRegulatoryComplianceObj
}
var sourcesWithoutSubAssessments = {
  sources: [for i in range(0, exportedDataTypesLengthIfEmpty): {
    eventSource: dataTypeMap[exportedDataTypes[i]]
    ruleSets: ruleSetsMap[exportedDataTypes[i]]
  }]
}
var sourcesWithSubAssessments = concat(subAssessmentSource, sourcesWithoutSubAssessments.sources)
var sources = ((isSecurityFindingsEnabled == bool('true')) ? sourcesWithSubAssessments : sourcesWithoutSubAssessments.sources)

resource VirtualMachines 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'VirtualMachines'
  properties: {
    pricingTier: pricingTierVMs
  }
}

resource SqlServers 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'SqlServers'
  properties: {
    pricingTier: pricingTierSqlServers
  }
  dependsOn: [
    VirtualMachines
  ]
}

resource AppServices 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'AppServices'
  properties: {
    pricingTier: pricingTierAppServices
  }
  dependsOn: [
    SqlServers
  ]
}

resource StorageAccounts 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'StorageAccounts'
  properties: {
    pricingTier: pricingTierStorageAccounts
  }
  dependsOn: [
    AppServices
  ]
}

resource SqlServerVirtualMachines 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'SqlServerVirtualMachines'
  properties: {
    pricingTier: pricingTierSqlServerVirtualMachines
  }
  dependsOn: [
    StorageAccounts
  ]
}

resource KubernetesService 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'KubernetesService'
  properties: {
    pricingTier: pricingTierKubernetesService
  }
  dependsOn: [
    SqlServerVirtualMachines
  ]
}

resource ContainerRegistry 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'ContainerRegistry'
  properties: {
    pricingTier: pricingTierContainerRegistry
  }
  dependsOn: [
    KubernetesService
  ]
}

resource KeyVaults 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'KeyVaults'
  properties: {
    pricingTier: pricingTierKeyVaults
  }
  dependsOn: [
    ContainerRegistry
  ]
}

resource Dns 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'Dns'
  properties: {
    pricingTier: pricingTierDns
  }
  dependsOn: [
    KeyVaults
  ]
}

resource Arm 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'Arm'
  properties: {
    pricingTier: pricingTierArm
  }
  dependsOn: [
    Dns
  ]
}

resource default 'Microsoft.Security/securityContacts@2020-01-01-preview' = if (!empty(emailSecurityContact)) {
  name: 'default'
  properties: {
    emails: emailSecurityContact
    notificationsByRole: {
      state: 'On'
      roles: [
        'Owner'
      ]
    }
    alertNotifications: {
      state: 'On'
      minimalSeverity: 'High'
    }
  }
}

resource ascResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName
  location: location
  tags: tags
  properties: {}
}

module securityAutomations 'Microsoft.Security/automations@2019-01-01-preview' = {
  name: 'nestedAutomationDeployment_${guidValue}'
  scope: resourceGroup(resourceGroupName)
  params: {
    variables_resourceGroupLocation: resourceGroupLocation
    variables_scopeDescription: scopeDescription
    variables_sources: sources
    workspaceResourceId: workspaceResourceId
  }
  dependsOn: [
    ascResourceGroup
  ]
}
