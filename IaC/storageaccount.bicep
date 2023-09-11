//param location string = resourceGroup().location
param storageAccountName string
//param defaultTags object

resource existing_storage_account 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// resource dataStorageName_resource 'Microsoft.Storage/storageAccounts@2023-01-01' = {
//   name: storageAccountName
//   location: location
//   tags: defaultTags
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

resource dataStorage_Blob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: existing_storage_account
  name: 'default'
  properties: {
    changeFeed: {
      enabled: false
    }
    restorePolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: true
      days: 7
    }
    isVersioningEnabled: false
  }
}

// resource fileServices_dataStorage_Blob 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
//   parent: existing_storage_account
//   name: 'default'
//   properties: {
//     protocolSettings: {
//       smb: {
//       }
//     }
//     cors: {
//       corsRules: []
//     }
//     shareDeleteRetentionPolicy: {
//       enabled: true
//       days: 7
//     }
//   }
// }

resource queueServices_dataStorage_Blob 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: existing_storage_account
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource tableServices_dataStorage_Blob 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: existing_storage_account
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource dataStorage_Blob_web 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: dataStorage_Blob
  name: '$web'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
    immutableStorageWithVersioning: {
      enabled: false
    }
  }

}

resource dataStorage_Blob_boston_hubway_data 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: dataStorage_Blob
  name: 'boston-hubway-data'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
    immutableStorageWithVersioning: {
      enabled: false
    }
  }

}

// output Storage Account Access Keys
var storageAccountKey1 = existing_storage_account.listKeys().keys[0].value
output out_storageAccountKey1 string = storageAccountKey1

// Save primary connections string
var storageAccountconnectionString = existing_storage_account.listKeys().keys[1].value

// Pass as output and saved in Key Vault
output out_storageAccountconnectionString string = storageAccountconnectionString
