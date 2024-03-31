// The following will create an Azure Function app on
// a consumption plan, along with a storage account
param location string = resourceGroup().location
param defaultTags object
param storageAccountNameBlob string

// Storage Account
resource storageAccountBlob 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountNameBlob
  tags: defaultTags
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    accessTier: 'Hot'
  }
}


// Blob Services for Storage Account
resource storageAccountBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccountBlob
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

resource dataStorage_Blob_web 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: storageAccountBlobServices
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
  parent: storageAccountBlobServices
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
var storageAccountBlobKey1 = storageAccountBlob.listKeys().keys[0].value
output out_storageAccountKey1 string = storageAccountBlobKey1

// Save primary connections string
var storageAccountBlobconnectionString = storageAccountBlob.listKeys().keys[1].value

// Pass as output and saved in Key Vault
output out_storageAccountBlobconnectionString string = storageAccountBlobconnectionString



// var secretAzureWebJobsStorage = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountBlob.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountBlob.listKeys().keys[0].value}'
// output out_AzureWebJobsStorage string = secretAzureWebJobsStorage
