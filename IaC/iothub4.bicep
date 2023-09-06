param location string
param iotHubName string
param defaultTags object

var storageAccountName = '${toLower('storiot')}${uniqueString(resourceGroup().id)}'
var storageEndpoint = 'HubwayTelemetryRoute'
var storageContainerName = '${toLower('stor')}results'

resource storageAccount_resource 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  tags: defaultTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource container_resource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-08-01' = {
  name: '${storageAccountName}/default/${storageContainerName}'
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

resource IoTHub 'Microsoft.Devices/IotHubs@2021-07-02' = {
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
        // eventHubs: [
        //   {
        //     connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount_resource.listKeys().keys[0].value}'
        //     containerName: storageContainerName
        //     fileNameFormat: '{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}'
        //     batchFrequencyInSeconds: 100
        //     maxChunkSizeInBytes: 104857600
        //     encoding: 'JSON'
        //     name: storageEndpoint
        //   }
        // ]
        storageContainers: [
          {
            connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount_resource.listKeys().keys[0].value}'
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
          condition: 'RoutingProperty = \'Hubway\'' //'level="storage"'
          endpointNames: [
            storageEndpoint
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

// resource iotDevice 'Microsoft.Devices/IotHubs@2022-11-15-preview' = {
//   parent: IoTHub
//   name: 'myIoTDevice'
// }


// resource storageAccount_resource 'Microsoft.Storage/storageAccounts@2021-08-01' = {
//   name: storageAccountName
//   tags: defaultTags
//   location: location
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'StorageV2'
//   properties: {
//     dnsEndpointType: 'Standard'
//     defaultToOAuthAuthentication: false
//     publicNetworkAccess: 'Enabled'
//     allowCrossTenantReplication: false
//     minimumTlsVersion: 'TLS1_2'
//     allowBlobPublicAccess: false
//     allowSharedKeyAccess: true
//     networkAcls: {
//       bypass: 'AzureServices'
//       virtualNetworkRules: []
//       ipRules: []
//       defaultAction: 'Allow'
//     }
//     supportsHttpsTrafficOnly: true
//     encryption: {
//       //requireInfrastructureEncryption: false
//       services: {
//         file: {
//           keyType: 'Account'
//           enabled: true
//         }
//         blob: {
//           keyType: 'Account'
//           enabled: true
//         }
//       }
//       keySource: 'Microsoft.Storage'
//     }
//     accessTier: 'Hot'
//   }
// }

// resource storageAccountBlob_resource 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
//   parent: storageAccount_resource
//   name: 'default'
//   properties: {
//     changeFeed: {
//       enabled: false
//     }
//     restorePolicy: {
//       enabled: false
//     }
//     containerDeleteRetentionPolicy: {
//       enabled: true
//       days: 7
//     }
//     cors: {
//       corsRules: []
//     }
//     deleteRetentionPolicy: {
//       allowPermanentDelete: false
//       enabled: true
//       days: 7
//     }
//     isVersioningEnabled: false
//   }
// }

// resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
//   parent: storageAccountBlob_resource
//   name: 'default'
//   properties: {
//     publicAccess: 'None'
//   }
// }

// resource dataStorageName_default_web 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
//   parent: storageAccountBlob_resource
//   name: '$web'
//   properties: {
//     defaultEncryptionScope: '$account-encryption-key'
//     denyEncryptionScopeOverride: false
//     publicAccess: 'None'
//     immutableStorageWithVersioning: {
//       enabled: false
//     }
//   }

// }

// resource dataStorageName_default_boston_hubway_data 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
//   parent: storageAccountBlob_resource
//   name: 'boston-hubway-data'
//   properties: {
//     defaultEncryptionScope: '$account-encryption-key'
//     denyEncryptionScopeOverride: false
//     publicAccess: 'None'
//     immutableStorageWithVersioning: {
//       enabled: false
//     }
//   }

// }

// resource IoTHub 'Microsoft.Devices/IotHubs@2022-04-30-preview' = {
//   name: iotHubName
//   location: location
//   tags: defaultTags
//   sku: {
//     name: 'B1'
//     capacity: 1
//   }
//   properties: {
//     eventHubEndpoints: {
//       events: {
//         retentionTimeInDays: 1
//         partitionCount: 4
//       }
//     }
//     routing: {
//       endpoints: {
//         storageContainers: [
//           {
//             connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount_resource.listKeys().keys[0].value}'
//             containerName: storageContainerName
//             fileNameFormat: '{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}'
//             batchFrequencyInSeconds: 100
//             maxChunkSizeInBytes: 104857600
//             encoding: 'JSON'
//             name: storageEndpoint
//           }
//         ]
//       }
//       routes: [
//         {
//           name: 'BostonHubwayTelemetryRoute'
//           source: 'DeviceMessages'
//           condition: 'RoutingProperty = \'Hubway\''
//           endpointNames: [
//             storageEndpoint
//           ]
//           isEnabled: true
//         }
//       ]
//       fallbackRoute: {
//         name: '$fallback'
//         source: 'DeviceMessages'
//         condition: 'true'
//         endpointNames: [
//           'events'
//         ]
//         isEnabled: true
//       }
//     }
//     messagingEndpoints: {
//       fileNotifications: {
//         lockDurationAsIso8601: 'PT1M'
//         ttlAsIso8601: 'PT1H'
//         maxDeliveryCount: 10
//       }
//     }
//     enableFileUploadNotifications: false
//     cloudToDevice: {
//       maxDeliveryCount: 10
//       defaultTtlAsIso8601: 'PT1H'
//       feedback: {
//         lockDurationAsIso8601: 'PT1M'
//         ttlAsIso8601: 'PT1H'
//         maxDeliveryCount: 10
//       }
//     }
//   }
// }
