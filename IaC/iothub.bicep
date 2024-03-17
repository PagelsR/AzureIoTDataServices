param location string
//param resourceGroupName string
param iotHubName string
param defaultTags object

// @secure()
param iotHub_connectionString string

@secure()
param iotHub_containerName string

resource iotHubName_resource 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  tags: defaultTags
  sku: {
    name: 'B1'
    //tier: 'Free'
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
        partitionCount: 2
      }
    }
    routing: {
      // endpoints: {
      //   serviceBusQueues: []
      //   serviceBusTopics: []
      //   eventHubs: [
      //     {
      //       connectionString: 'Endpoint=sb://rg-pagelsr-iotdataservices-eventhub.servicebus.windows.net:5671/;SharedAccessKeyName=iothubroutes_${iotHubName};SharedAccessKey=****;EntityPath=hubwaytelemetry'
      //       authenticationType: 'keyBased'
      //       name: 'HubwayTelemetryRoute'
      //       id: '8a99b198-d711-4b5a-8486-3c38bac1df07'
      //       subscriptionId: '295e777c-2a1b-456a-989e-3c9b15d52a8e'
      //       resourceGroup: resourceGroupName
      //     }
      //   ]
      //   storageContainers: []
      //   cosmosDBSqlCollections: []
      // }
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
        connectionString: iotHub_connectionString
        containerName: iotHub_containerName
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

// resource iothub_addroute 'Microsoft.Devices/IotHubs/Routes@2020-03-01' = {
//   name: 'HubwayTelemetryRoutev2'
//   parent: iotHubName_resource
//   properties: {
//     condition: 'Hubway'
//     endpointNames: [
//       'HubwayTelemetry'
//     ]
//   }
// }

resource iothub_addroute 'Microsoft.Devices/IotHubs/Routing@2020-03-01' = {
  name: 'HubwayTelemetryRoutev2'
  parent: iotHubName_resource
  properties: {
    condition: 'Hubway'
    endpointNames: [
      'HubwayTelemetry'
    ]
  }
}
