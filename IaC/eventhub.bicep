param location string = resourceGroup().location
param eventHubName string
param eventHubNamespaceName string
param iotHubName string
param defaultTags object
param iotTelemetryRouteName string

// Defind the Event Hub Namespace
// resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview'= {
//   name: eventHubNamespaceName
//   location: location
//   tags: defaultTags
//   sku: {
//     name: 'Standard'
//     tier: 'Standard'
//     capacity: 1
//   }
//   properties: {
//     minimumTlsVersion: '1.2'
//     publicNetworkAccess: 'Enabled'
//     disableLocalAuth: false
//     zoneRedundant: true
//     isAutoInflateEnabled: false
//     maximumThroughputUnits: 0
//     kafkaEnabled: true
//   }
// }

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  tags: defaultTags
  properties: {}
}

// Define the Event Hub
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

// Define the Authorization Rule
resource iotHubAuthorizedToSendRule 'Microsoft.EventHub/namespaces/authorizationrules@2021-01-01-preview' = {
  parent: eventHubNamespace
  name: 'IoTHubCanSend'
  properties: {
    rights: [
      'Send'
      'Listen'
    ]
  }
}
 // Define the Consumer Group
resource eventHubName_hubwaytelemetry_hubwaycg 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-01-01-preview' = {
  parent: eventHubName_hubwaytelemetry
  name: 'OVfietscg'
  properties: {
  }

}

// Define the IoT Hub
resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 2
      }
    }
    routing: {
      routes: [
        {
          name: iotTelemetryRouteName //'BostonHubwayTelemetryRoute'
          source: 'DeviceMessages'
          condition: 'RoutingProperty = \'Hubway\''
          endpointNames: [
            'HubwayTelemetryRoute'
          ]
          isEnabled: true
        }
      ]
      endpoints: {
        eventHubs: [
          {
            name: iotTelemetryRouteName //'HubwayTelemetryRoute'
            connectionString: iotHubAuthorizedToSendRule.listKeys().primaryConnectionString
          }
        ]
      }
    }
  }
}

var AuthorizedeventHubNamespaceConnectionString = listKeys(iotHubAuthorizedToSendRule.id, iotHubAuthorizedToSendRule.apiVersion).primaryConnectionString

// Output our variables
output out_eventHubPrimaryConnectionString string = AuthorizedeventHubNamespaceConnectionString
