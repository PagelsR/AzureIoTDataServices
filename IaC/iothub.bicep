param location string
param iotHubName string
param defaultTags object

param EventHubPrimaryConnectionString string

//param AzureWebJobsStorageName string

var storageAccountForIoTName = '${toLower('storiot')}${uniqueString(resourceGroup().id)}'
var storageContainerName = '${toLower('storiot')}results'
var storageEndpoint = 'contoso-StorageEndpont'

// Storage Account
// resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
//   name: storageAccountName
// }

resource storageAccount_resource 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountForIoTName
  location: location
  tags: defaultTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// resource iotStorageContainer_resource 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
//   name: '${storageAccountForIoTName}/default/${storageContainerName}'
//   properties: {
//     publicAccess: 'None'
//   }
//   dependsOn: [
//     storageAccount_resource
//   ]
// }

resource iotStorageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccountForIoTName}/default/${storageContainerName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
     storageAccount_resource
   ]
}

// resource existing_eventHubName_resource 'Microsoft.EventHub/namespaces@2022-10-01-preview' existing =  {
// name: eventHubNamespaceName
// }


resource IoTHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  location: location
  tags: defaultTags
  sku: {
    name: 'S1'
    capacity: 1
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 4
      }
    }
    routing: {
      endpoints: {
        eventHubs: [
          // setup during deployment using az cli using az iot hub routing-endpoint create
          //
          // {
          //   connectionString: EventHubPrimaryConnectionString
          //   authenticationType: 'keyBased'
          //   name:  'HubwayTelemetryRoute'
          //   id: '8a99b198-d711-4b5a-8486-3c38bac1df07'
          //   subscriptionId: '295e777c-2a1b-456a-989e-3c9b15d52a8e'
          //   resourceGroup: resourceGroup().name
          // }
        ]
        storageContainers: [
          {
            connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountForIoTName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount_resource.listKeys().keys[0].value}'
            containerName: storageContainerName
            fileNameFormat: '{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}'
            batchFrequencyInSeconds: 100
            maxChunkSizeInBytes: 104857600
            encoding: 'JSON'
            name: storageEndpoint
          }
        ]
      }
      routes: [
        // Setup during deployment using az cli az iot hub update
        //
        // {
        //   name: 'BostonHubwayTelemetryRoute2'
        //   source: 'DeviceMessages'
        //   condition: 'RoutingProperty = \'Hubway\''
        //   endpointNames: [
        //     'HubwayTelemetryRoute2'
        //   ]
        //   isEnabled: true
        // }
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
  }
}

// var deviceId = 'raspberrypi-detroit-909'

// resource iotDevice 'Microsoft.Devices/IotHubs/devices@2020-03-01' = {
//    parent: IoTHub
//    name: deviceId
//   properties: {
//     deviceId: deviceId
//   }
// }


// resource iothub_addroute 'Microsoft.Devices/IotHubs/Routing@2020-03-01' = {
//   name: 'HubwayTelemetryRoutev2'
//   parent: IoTHub
//   properties: {
//     condition: 'Hubway'
//     endpointNames: [
//       'HubwayTelemetry'
//     ]
//   }
// }


// // Correct usage of listKeys function
// var deviceKeys = listKeys(iotDevice.id, IoTHub.apiVersion)

// // Get the primary connection string
// var deviceConnectionString = deviceKeys.primaryConnectionString

// // Output the connection string
// output out_deviceConnectionString string = deviceConnectionString
