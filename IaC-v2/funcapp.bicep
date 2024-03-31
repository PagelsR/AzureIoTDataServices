// The following will create an Azure Function app on
// a consumption plan, along with a storage account
param location string = resourceGroup().location
param functionAppName string
param functionAppServicePlanName string
param defaultTags object
param storageAccountNameFuncApp string

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  kind: 'functionapp,linux'
  location: location
  tags: defaultTags
  properties: {
    siteConfig: {
    //   appSettings: [
    //     {
    //       name: 'FUNCTIONS_WORKER_RUNTIME'
    //       value: 'python'
    //     }
    //     {
    //       name: 'FUNCTIONS_EXTENSION_VERSION'
    //       value: '~4'
    //     }
    //     {
    //       name: 'AzureWebJobsStorage'
    //       value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value}'
    //     }
    //   ]
    netFrameworkVersion: 'v4.0'
    }
    serverFarmId: hostingPlan.id
    clientAffinityEnabled: false
  }
  identity: {
    type:'SystemAssigned'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: functionAppServicePlanName
  location: location
  kind: 'linux'
  properties: {
    reserved: true
  }
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
}

resource storageAccountFuncApp 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountNameFuncApp
  tags: defaultTags
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

var secretAzureWebJobsStorageFuncApp = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountFuncApp.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountFuncApp.listKeys().keys[0].value}'
output out_funcAppServiceprincipalId string = functionApp.identity.principalId
output out_AzureWebJobsStorageFuncApp string = secretAzureWebJobsStorageFuncApp
