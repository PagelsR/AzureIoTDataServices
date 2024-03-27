param location string = resourceGroup().location
var iotHubName = 'myIoTHub-Test'
var eventHubNamespaceName = 'myEventHubNamespace-Test'
var eventHubName = 'myEventHub-Test'

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

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2018-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2018-01-01-preview' = {
  parent: eventHubNamespace
  name: eventHubName
  properties: {
    messageRetentionInDays: 7
    partitionCount: 2
  }
}

resource eventHubAuthorizationRule 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2017-04-01' = {
  parent: eventHub
  name: 'RootManageSharedAccessKey'
  dependsOn: [
    eventHub
  ]
  properties: {
    rights: [
      'Listen'
      'Send'
      'Manage'
    ]
  }
}

var eventHubKeys = listKeys(eventHubAuthorizationRule.id, '2018-01-01-preview')

// Correct resource types need to be used for iotHubEndpoint and iotHubRoute
// resource iotHubEndpoint 'Microsoft.Devices/IotHubs/eventHubEndpoints@2020-03-01' = {
//   parent: iotHub
//   name: 'HubwayTelemetryRoute'
//   properties: {
//     connectionString: 'Endpoint=${eventHubKeys.primaryConnectionString};EntityPath=${eventHub.name}'
//     containerName: eventHubName
//   }
// }

// resource iotHubRoute 'Microsoft.Devices/IotHubs/Routes@2020-03-01' = {
//   parent: iotHub
//   name: 'BostonHubwayTelemetryRoute'
//   properties: {
//     source: 'DeviceMessages'
//     condition: 'RoutingProperty = \'Hubway\''
//     endpointNames: [
//       'HubwayTelemetryRoute'
//     ]
//     isEnabled: true
//   }
//   dependsOn: [
//     iotHubEndpoint
//   ]
// }

