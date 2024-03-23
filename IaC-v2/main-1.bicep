//param deviceName string = 'Detroit-909'
//param endpointName string = 'HubwayTelemetryRoute'
//param routeName string = 'BostonHubwayTelemetryRoute'
//param condition string = 'RoutingProperty = \'Hubway\''
param resourceGroupName string = resourceGroup().name
param location string = resourceGroup().location
var iotHubName = 'iot-${uniqueString(resourceGroup().id)}'
var eventHubName = 'evh-${uniqueString(resourceGroup().id)}'
var eventHubNamespaceName = 'evhns-${uniqueString(resourceGroup().id)}'

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
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
}

resource eventHubName_hubwaytelemetry 'Microsoft.EventHub/namespaces/eventhubs@2021-01-01-preview' = {
  parent: eventHubNamespace
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

resource eventHubName_consumergroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-01-01-preview' = {
  parent: eventHubNamespace
  name: 'hubwaycg'
  properties: {
}

resource device 'Microsoft.Devices/IotHubs/devices@2020-03-01' = {
  parent: iotHub
  name: 'Detroit-909' //deviceName
}

// Get the keys of the Event Hub namespace
var eventHubNamespaceKeys = listKeys(eventHubNamespace.id, eventHubNamespace.apiVersion)

resource endpoint 'Microsoft.Devices/IotHubs/RoutingEndpoints@2020-03-01' = {
  parent: iotHub
  name: endpointName
  properties: {
    connectionString: eventHubNamespaceKeys.primaryConnectionString
    endpointType: 'EventHub'
    entityPath: eventHubName
    resourceGroup: resourceGroupName
    subscriptionId: subscription().subscriptionId
  }
}

resource route 'Microsoft.Devices/IotHubs/Routes@2020-03-01' = {
  parent: iotHub
  name: 'BostonHubwayTelemetryRoute'
  properties: {
    source: 'DeviceMessages'
    condition: 'RoutingProperty = \'Hubway\''
    endpointNames: [
      'HubwayTelemetryRoute'
    ]
    isEnabled: true
  }
}
