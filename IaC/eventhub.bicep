param location string = resourceGroup().location
param eventHubName string
param eventHubNamespaceName string
param defaultTags object

resource eventHubName_resource 'Microsoft.EventHub/namespaces@2022-10-01-preview' = {
  name: eventHubName
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

resource eventHubName_RootManageSharedAccessKey 'Microsoft.EventHub/namespaces/authorizationrules@2022-10-01-preview' = {
  parent: eventHubName_resource
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource eventHubName_hubwaytelemetry 'Microsoft.EventHub/namespaces/eventhubs@2022-10-01-preview' = {
  parent: eventHubName_resource
  name: 'hubwaytelemetry'
  properties: {
    retentionDescription: {
      cleanupPolicy: 'Delete'
      retentionTimeInHours: 24
    }
    messageRetentionInDays: 1
    partitionCount: 1
    status: 'Active'
  }
}

resource eventHubName_default 'Microsoft.EventHub/namespaces/networkrulesets@2022-10-01-preview' = {
  parent: eventHubName_resource
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: []
    ipRules: []
    trustedServiceAccessEnabled: false
  }
}

resource eventHubName_hubwaytelemetry_eventHubNamespaceName 'Microsoft.EventHub/namespaces/eventhubs/authorizationrules@2022-10-01-preview' = {
  parent: eventHubName_hubwaytelemetry
  name: eventHubNamespaceName
  properties: {
    rights: [
      'Send'
    ]
  }

}

resource eventHubName_hubwaytelemetry_Default 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-10-01-preview' = {
  parent: eventHubName_hubwaytelemetry
  name: '$Default'
  properties: {
  }
}

resource eventHubName_hubwaytelemetry_hubwaycg 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2022-10-01-preview' = {
  parent: eventHubName_hubwaytelemetry
  name: 'hubwaycg'
  properties: {
  }

}

//output rootManageConnectionString string = eventHubName_hubwaytelemetry_eventHubNamespaceName.properties.primaryConnectionString


// Find endpoint of policy
//var eventHubEndpoint = '${eventHubName_resource.id}/AuthorizationRules/${eventHubName_hubwaytelemetry_eventHubNamespaceName.name}'

// Save primary connections string
//var serviceBusConnectionString = listKeys(eventHubEndpoint, eventHubName_resource.apiVersion).primaryConnectionString

// Pass as output and saved in Key Vault
//output out_servicebusConnectionString string = serviceBusConnectionString

// Find endpoint of policy
//var eventHubEndpointPrimary = eventHubName_hubwaytelemetry_eventHubNamespaceName.listKeys().primaryConnectionString
var eventHubEndpointPrimary = eventHubName_resource.listKeys().primaryConnectionString

output out_eventHubEndpointPrimary string = eventHubEndpointPrimary
