param location string = resourceGroup().location
param storageAccountName string
param defaultTags object

resource dataStorageName_resource 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: defaultTags
  sku: {
    name: 'Standard_LRS'
    //tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      //requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource dataStorageName_default 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: dataStorageName_resource
  name: 'default'
  // sku: {
  //   name: 'Standard_LRS'
  //   tier: 'Standard'
  // }
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

resource Microsoft_Storage_storageAccounts_fileServices_dataStorageName_default 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: dataStorageName_resource
  name: 'default'
  // sku: {
  //   name: 'Standard_LRS'
  //   tier: 'Standard'
  // }
  properties: {
    protocolSettings: {
      smb: {
      }
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_dataStorageName_default 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: dataStorageName_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_dataStorageName_default 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: dataStorageName_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource dataStorageName_default_web 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: dataStorageName_default
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

resource dataStorageName_default_boston_hubway_data 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: dataStorageName_default
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
//output storageAccountKey1 dataStorageName_resource.listKeys().keys[0].value
var storageAccountKey1 = dataStorageName_resource.listKeys().keys[0].value
output out_storageAccountKey1 string = storageAccountKey1

// var configStoreConnectionString = dataStorageName_resource.listKeys().keys[0].connectionString
// output out_configStoreConnectionString string = configStoreConnectionString

// Save primary connections string
var storageAccountconnectionString = dataStorageName_resource.listKeys().keys[1].value

// Pass as output and saved in Key Vault
output out_storageAccountconnectionString string = storageAccountconnectionString
