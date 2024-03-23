param iotHubName string = 'myIoTHub-Test'
param eventHubNamespaceName string = 'myEventHubNamespace-Test'
param eventHubName string = 'myEventHub-Test'
param deviceName string = 'Detroit-909'
param endpointName string = 'HubwayTelemetryRoute'
param routeName string = 'BostonHubwayTelemetryRoute'
param condition string = 'RoutingProperty = \'Hubway\''

resource iotHub 'Microsoft.Devices/IotHubs@2020-03-01' = {
  name: iotHubName
  location: resourceGroup().location
  sku: {
    name: 'Standard'
    tier: 'Standard'
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

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2017-04-01' = {
  name: eventHubNamespaceName
  location: resourceGroup().location
  sku: {
    tier: 'Standard'
    capacity: 1
  }
}

resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2017-04-01' = {
  name: '${eventHubNamespace.name}/${eventHubName}'
  location: resourceGroup().location
}

resource device 'Microsoft.Devices/IotHubs/devices@2020-03-01' = {
  parent: iotHub
  name: deviceName
}

resource endpoint 'Microsoft.Devices/IotHubs/RoutingEndpoints@2020-03-01' = {
  parent: iotHub
  name: endpointName
  properties: {
    connectionString: 'Endpoint=${eventHubNamespace.properties.endpoint};SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=${listKeys(eventHubNamespace.id, eventHubNamespace.apiVersion).primaryConnectionString}'
    endpointType: 'EventHub'
    entityPath: eventHubName
    resourceGroup: resourceGroup().name
    subscriptionId: subscription().subscriptionId
  }
}

resource route 'Microsoft.Devices/IotHubs/Routes@2020-03-01' = {
  parent: iotHub
  name: routeName
  properties: {
    source: 'DeviceMessages'
    condition: condition
    endpointNames: [
      endpointName
    ]
    isEnabled: true
  }
}
