param location string = resourceGroup().location
var iotHubName = 'iothubname-${uniqueString(resourceGroup().id)}'
var eventHubName = 'hubwaytelemetry'
var eventHubNamespaceName = 'evhnamespace-${uniqueString(resourceGroup().id)}'

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  properties: {}
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' = {
  name: eventHubName
  parent: eventHubNamespace
  properties: {
    partitionCount: 2
    messageRetentionInDays: 7
  }
}

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
          name: 'BostonHubwayTelemetryRoute'
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
            name: 'HubwayTelemetryRoute'
            connectionString: iotHubAuthorizedToSendRule.listKeys().primaryConnectionString
          }
        ]
      }
    }
  }
}

output out_iotHubName string = iotHubName
