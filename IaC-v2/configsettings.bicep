param keyvaultName string
param azuremapname string
param functionAppName string
param KeyVault_AzureWebJobsStorageName string
param KeyVault_Shared_Access_Key_EVENTHUBName string
param KeyVault_Shared_Access_Key_DOCUMENTDBName string
param KeyVault_Azure_Maps_Subscription_KeyName string
param KeyVault_WebsiteContentAzureFileConnectionStringName string

@secure()
param KeyVault_AzureWebJobsStorageValue string

@secure()
param KeyVault_Shared_Access_Key_EVENTHUBValue string

@secure()
param KeyVault_Shared_Access_Key_DOCUMENTDBValue string

@secure()
param KeyVault_Azure_Maps_Subscription_KeyValue string

param appInsightsInstrumentationKey string
param appInsightsConnectionString string

param KeyVault_ClientIdName string

@secure()
param KeyVault_ClientIdValue string

param KeyVault_MapsSubscriptionKeyName string

@secure()
param AzObjectIdPagels string

@secure()
param ADOServiceprincipalObjectId string

@secure()
param funcAppServiceprincipalId string


param tenant string

// Define KeyVault accessPolicies
param accessPolicies array = [
  {
    tenantId: tenant
    objectId: funcAppServiceprincipalId
    permissions: {
      keys: [
        'Get'
        'List'
      ]
      secrets: [
        'Get'
        'List'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: AzObjectIdPagels
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
        'set'
        'delete'
      ]
    }
  }
  {
    tenantId: tenant
    objectId: ADOServiceprincipalObjectId
    permissions: {
      keys: [
        'get'
        'list'
      ]
      secrets: [
        'get'
        'list'
      ]
    }
  }
]

// Reference Existing resource
resource existing_keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyvaultName
}

// Create KeyVault accessPolicies
resource keyvaultaccessmod 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: 'add'
  parent: existing_keyvault
  properties: {
    accessPolicies: accessPolicies
  }
}

// Reference Existing resource
resource existing_azuremaps 'Microsoft.Maps/accounts@2023-06-01' existing = {
  name: azuremapname
}
var AzureMapsSubscriptionKeyString = existing_azuremaps.listKeys().primaryKey

// Create KeyVault Secrets
resource secret1 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: KeyVault_ClientIdName
  parent: existing_keyvault
  properties: {
    value: KeyVault_ClientIdValue
  }
}

// Create KeyVault Secrets
resource secret2 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: KeyVault_MapsSubscriptionKeyName
  parent: existing_keyvault
  properties: {
    value: AzureMapsSubscriptionKeyString
  }
}

//create secret for Func App
resource secret3 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: KeyVault_AzureWebJobsStorageName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_AzureWebJobsStorageValue
  }
}
// create secret for Func App
resource secret4 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: KeyVault_WebsiteContentAzureFileConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_AzureWebJobsStorageValue
  }
}
// create secret for Func App
resource secret5 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: KeyVault_Shared_Access_Key_EVENTHUBName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_Shared_Access_Key_EVENTHUBValue
  }
}
// create secret for Func App
resource secret6 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: KeyVault_Shared_Access_Key_DOCUMENTDBName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_Shared_Access_Key_DOCUMENTDBValue
  }
}
// create secret for Func App
resource secret7 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: KeyVault_Azure_Maps_Subscription_KeyName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_Azure_Maps_Subscription_KeyValue
  }
}

//     'AzureWebJobs.HubwayEventHubTriggerRead.Disabled': 'true'

// Reference Existing resource
resource existing_funcAppService 'Microsoft.Web/sites@2023-01-01' existing = {
  name: functionAppName
}

// Create Web sites/config 'appsettings' - Function App
resource funcAppSettingsStrings 'Microsoft.Web/sites/config@2023-01-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: existing_funcAppService
  properties: {
    AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_AzureWebJobsStorageName})'
    Shared_Access_Key_EVENTHUB: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_Shared_Access_Key_EVENTHUBName})'
    Shared_Access_Key_DOCUMENTDB: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_Shared_Access_Key_DOCUMENTDBName})'
    Azure_Maps_Subscription_Key: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_Azure_Maps_Subscription_KeyName})'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    FUNCTIONS_EXTENSION_VERSION: '~4'
    WEBSITE_CONTENTSHARE: functionAppName
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_WebsiteContentAzureFileConnectionStringName})'
    'AzureWebJobs.SendToIoTHub.Disabled': 'true'
  }
  dependsOn: [
    secret3
    secret5
    secret6
    secret7
  ]
}

