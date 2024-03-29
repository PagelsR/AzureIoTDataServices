param location string
param iotHubName string
param defaultTags object

@secure()
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
          {
            name: 'HubwayTelemetryRoute'
            connectionString: EventHubPrimaryConnectionString
          }
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

