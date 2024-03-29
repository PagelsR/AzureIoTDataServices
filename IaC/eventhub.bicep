param location string = resourceGroup().location
param eventHubName string
param eventHubNamespaceName string
param defaultTags object

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview'= {
  name: eventHubNamespaceName
  location: location
  tags: defaultTags
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: true
    isAutoInflateEnabled: false
    maximumThroughputUnits: 0
    kafkaEnabled: true
  }
}

resource eventHubName_hubwaytelemetry 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 24
    }
    messageRetentionInDays: 7
    partitionCount: 2
    status: 'Active'
  }
}
resource iotHubAuthorizedToSendRule 'Microsoft.EventHub/namespaces/authorizationrules@2021-01-01-preview' = {
  parent: eventHubNamespace
  // name: 'RootManageSharedAccessKey'
  name: 'IoTHubCanSend'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}



// resource eventHubName_default 'Microsoft.EventHub/namespaces/networkrulesets@2021-01-01-preview' = {
//   parent: eventHubName_resource
//   name: 'default'
//   properties: {
//     publicNetworkAccess: 'Enabled'
//     defaultAction: 'Allow'
//     virtualNetworkRules: []
//     ipRules: []
//     trustedServiceAccessEnabled: false
//   }
// }

// resource eventHubName_hubwaytelemetry_eventHubNamespaceName 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2021-01-01-preview' = {
//   parent: eventHubName_hubwaytelemetry
//   name: eventHubNamespaceName
//   properties: {
//     rights: [
//       'Send'
//     ]
//   }

// }

// resource eventHubName_hubwaytelemetry_Default 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-01-01-preview' = {
//   parent: eventHubName_hubwaytelemetry
//   name: '$Default'
//   properties: {
//   }
// }

resource eventHubName_hubwaytelemetry_hubwaycg 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-01-01-preview' = {
  parent: eventHubName_hubwaytelemetry
  name: 'hubwaycg'
  properties: {
  }

}
//var eventHubNamespaceConnectionString = listKeys(eventHubName_RootManageSharedAccessKey.id, eventHubName_RootManageSharedAccessKey.apiVersion).primaryConnectionString
//var eventHubNamespaceConnectionString = eventHubName_RootManageSharedAccessKey.listKeys().primaryConnectionString
var AuthorizedeventHubNamespaceConnectionString = iotHubAuthorizedToSendRule.listKeys().primaryConnectionString

output eventHubNamespaceConnectionString string = AuthorizedeventHubNamespaceConnectionString
output out_eventHubPrimaryConnectionString string = AuthorizedeventHubNamespaceConnectionString
