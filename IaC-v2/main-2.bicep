param location string = resourceGroup().location
var iotHubName = 'iot-${uniqueString(resourceGroup().id)}'
var eventHubName = 'evh-${uniqueString(resourceGroup().id)}'

resource iotHub 'Microsoft.Devices/IotHubs@2020-03-01' = {
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
  }
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2021-01-01-preview' = {
  name: eventHubName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2021-01-01-preview' = {
  parent: eventHubNamespace
  name: 'hubwaytelemetry'
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
    status: 'Active'
  }
}

resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-01-01-preview' = {
  parent: eventHub
  name: 'hubwaycg'
}

// resource device 'Microsoft.Devices/IotHubs/devices@2020-03-01' = {
//   parent: iotHub
//   name: 'Detroit-909'
// }

// Get the keys of the Event Hub namespace
//var eventHubNamespaceKeys = listKeys(eventHubNamespace.id, eventHubNamespace.apiVersion)
var eventHubNamespaceKeys = eventHubNamespace.listKeys()

// resource endpoint 'Microsoft.Devices/IotHubs/RoutingEndpoints@2020-03-01' = {
//   parent: iotHub
//   name: 'HubwayTelemetryRoute'
//   properties: {
//     connectionString: eventHubNamespaceKeys.primaryConnectionString
//     endpointType: 'EventHub'
//   }
// }
//     entityPath: eventHub.name
//     resourceGroup: resourceGroup().name
//     subscriptionId: subscription().subscriptionId
//   }
// }

//resource route 'Microsoft.Devices/IotHubs/Routes@2020-03-01' = {
//  parent: iotHub
//  name: 'BostonHubwayTelemetryRoute'
//  properties: {
//    source: 'DeviceMessages'
//    condition: 'RoutingProperty = \'Hubway\''
//    endpointNames: [
//      endpoint.name
//    ]
//    isEnabled: true
//  }
//}
