param location string = resourceGroup().location
//param eventHubName string = 'hubwaytelemetry'
param eventHubName string
param eventHubNamespaceName string
param defaultTags object
param eventHubConsumerGroup string

// Define the Event Hub Namespace
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: eventHubNamespaceName
  tags: defaultTags
  location: location
  identity: {
    type: 'SystemAssigned'
  }
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
         'Listen'
         'Manage'
      ]
   }
}

 // Define the Consumer Group
 resource eventHubName_telemetry_cg 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-01-01-preview' = {
  parent: eventHub
  name: eventHubConsumerGroup //'OVfietscg'
  properties: {
  }

}

var AuthorizedeventHubNamespaceConnectionString = iotHubAuthorizedToSendRule.listKeys().primaryConnectionString
output out_eventHubPrimaryConnectionString string = AuthorizedeventHubNamespaceConnectionString
