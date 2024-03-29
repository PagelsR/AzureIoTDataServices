param location string = resourceGroup().location
param eventHubName string = 'hubwaytelemetry'
param eventHubNamespaceName string
param defaultTags object

// Define the Event Hub Namespace
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: eventHubNamespaceName
  tags: defaultTags
  location: location
  properties: {}
}

// Define the Event Hub
resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  name: eventHubName
  parent: eventHubNamespace
  properties: {
    partitionCount: 2
    messageRetentionInDays: 7
  }
}

// Define the Authorization Rule
resource iotHubAuthorizedToSendRule 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2017-04-01' = {
  name: 'iothubCanSend'
  parent: eventHub
   properties: {
      rights: [
         'Send'
      ]
   }
}

 // Define the Consumer Group
 resource eventHubName_hubwaytelemetry_hubwaycg 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-01-01-preview' = {
  parent: eventHub
  name: 'hubwaycg'
  properties: {
  }

}

var AuthorizedeventHubNamespaceConnectionString = iotHubAuthorizedToSendRule.listKeys().primaryConnectionString
output out_eventHubPrimaryConnectionString string = AuthorizedeventHubNamespaceConnectionString
