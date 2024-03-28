param location string = resourceGroup().location
var iotHubName = 'iothubname-${uniqueString(resourceGroup().id)}'
var eventHubName = 'hubwaytelemetry'
var eventHubNamespaceName = 'evhnamespace-${uniqueString(resourceGroup().id)}'

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2018-01-01-preview' = {
  name: eventHubNamespaceName
  location: location
  properties: {}
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2018-01-01-preview' = {
  name: '${eventHubNamespace.name}/${eventHubName}'
  properties: {
    partitionCount: 2
    messageRetentionInDays: 7
  }
}


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
        serviceBusQueues: [
          {
            connectionString: 'Endpoint=${eventHubNamespace.properties.serviceBusEndpoint};SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=${listKeys(eventHubNamespace.id, eventHubNamespace.apiVersion).primaryConnectionString};EntityPath=${eventHubName}'
            name: 'HubwayTelemetryRoute'
          }
        ]
      }
    }
  }
}

