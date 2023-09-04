param location string
//param resourceGroupName string
param iotHubName string
param defaultTags object
param eventHubNamespaceName string
param eventHubName string
param routeName string = 'BostonHubwayTelemetryRoute'
param conditionExpression string = 'RoutingProperty = "Hubway"'

@secure()
param iotHubName_connectionString string

@secure()
param iotHubName_containerName string

resource iotHubName_resource 'Microsoft.Devices/IotHubs@2022-11-15-preview' = {
  name: iotHubName
  location: location
  tags: defaultTags
  sku: {
    name: 'B1'
    capacity: 1
  }
  identity: {
    type: 'None'
  }
  properties: {
    ipFilterRules: []
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 4
      }
    }
    routing: {
      endpoints: {
        serviceBusQueues: []
        serviceBusTopics: []
        eventHubs: []
        storageContainers: []
        cosmosDBSqlCollections: []
      }
      routes: []
      fallbackRoute: {
        name: '$fallback'
        source: 'DeviceMessages'
        condition: 'true'
        endpointNames: [
          'events'
        ]
        isEnabled: true
      }
    }
    storageEndpoints: {
      '$default': {
        sasTtlAsIso8601: 'PT1H'
        connectionString: iotHubName_connectionString
        containerName: iotHubName_containerName
      }
    }
    messagingEndpoints: {
      fileNotifications: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    enableFileUploadNotifications: false
    cloudToDevice: {
      maxDeliveryCount: 10
      defaultTtlAsIso8601: 'PT1H'
      feedback: {
        lockDurationAsIso8601: 'PT1M'
        ttlAsIso8601: 'PT1H'
        maxDeliveryCount: 10
      }
    }
    features: 'None'
    disableLocalAuth: false
    allowedFqdnList: []
    enableDataResidency: false
  }
}

// resource route 'Microsoft.Devices/IotHubs/eventHubEndpoints/ConsumerGroups@2022-11-15-preview' = {
//   parent: iotHubName_resource
//   name: routeName
//   properties: {
//     isEnabled: true
//     source: 'DeviceMessages'
//     condition: conditionExpression
//     endpointNames: [
//       'EventHubEndpoint'
//     ]
//   }
// }

// resource existing_eventHubName_resource 'Microsoft.EventHub/namespaces@2022-10-01-preview' existing =  {
// name: eventHubNamespaceName
// }

// resource endpoint 'Microsoft.Devices/IotHubs@2022-11-15-preview' = {
//   parent: iotHubName_resource
//   name: 'EventHubEndpoint'
//   properties: {
//     endpointType: 'azureeventhub'
//     resourceId: existing_eventHubName_resource.id
//   }
// }
