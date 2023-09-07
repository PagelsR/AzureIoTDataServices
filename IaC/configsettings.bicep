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

//param functionAppName string
// param secret_AzureWebJobsStorageName string
// param secret_WebsiteContentAzureFileConnectionStringName string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string

// param KeyVault_MapsClientIdName string

// @secure()
// param KeyVault_MapsClientIdValue string

// param KeyVault_MapsSubscriptionKeyName string

// @secure()
// param KeyVault_MapsSubscriptionKeyValue string

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

// @secure()
// param secret_AzureWebJobsStorageValue string

param tenant string
//param mysubscription string = subscription();

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
resource existing_keyvault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyvaultName
}

// Create KeyVault accessPolicies
resource keyvaultaccessmod 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: 'add'
  parent: existing_keyvault
  properties: {
    accessPolicies: accessPolicies
  }
}

// Reference Existing resource
resource existing_azuremaps 'Microsoft.Maps/accounts@2021-12-01-preview' existing = {
  name: azuremapname
}
var AzureMapsSubscriptionKeyString = existing_azuremaps.listKeys().primaryKey

// Create KeyVault Secrets
resource secret1 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_ClientIdName
  parent: existing_keyvault
  properties: {
    value: KeyVault_ClientIdValue
  }
}

// Create KeyVault Secrets
resource secret2 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_MapsSubscriptionKeyName
  parent: existing_keyvault
  properties: {
    value: AzureMapsSubscriptionKeyString
  }
}

//create secret for Func App
resource secret3 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_AzureWebJobsStorageName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_AzureWebJobsStorageValue
  }
}
// create secret for Func App
resource secret4 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_WebsiteContentAzureFileConnectionStringName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_AzureWebJobsStorageValue
  }
}
// create secret for Func App
resource secret5 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_Shared_Access_Key_EVENTHUBName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_Shared_Access_Key_EVENTHUBValue
  }
}
// create secret for Func App
resource secret6 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_Shared_Access_Key_DOCUMENTDBName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_Shared_Access_Key_DOCUMENTDBValue
  }
}
// create secret for Func App
resource secret7 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_Azure_Maps_Subscription_KeyName
  parent: existing_keyvault
  properties: {
    contentType: 'text/plain'
    value: KeyVault_Azure_Maps_Subscription_KeyValue
  }
}

// Reference Existing resource
resource existing_funcAppService 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionAppName
}
// Create Web sites/config 'appsettings' - Function App
resource funcAppSettingsStrings 'Microsoft.Web/sites/config@2022-09-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: existing_funcAppService
  properties: {
    AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_AzureWebJobsStorageName})'
    WebsiteContentAzureFileConnectionString: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_WebsiteContentAzureFileConnectionStringName})'
    // AzureWebJobsStorage: KeyVault_AzureWebJobsStorageValue
    // WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: KeyVault_AzureWebJobsStorageValue
    Shared_Access_Key_EVENTHUB: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_Shared_Access_Key_EVENTHUBName})'
    Shared_Access_Key_DOCUMENTDB: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_Shared_Access_Key_DOCUMENTDBName})'
    Azure_Maps_Subscription_Key: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${KeyVault_Azure_Maps_Subscription_KeyName})'
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnectionString
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    FUNCTIONS_EXTENSION_VERSION: '~4'
  }
  dependsOn: [
    secret3
    secret5
    secret6
    secret7
  ]
}

// resource existing_iotHubName_resource 'Microsoft.Devices/IotHubs@2022-04-30-preview' existing = {

// {

// Add a route to IoT Hub to existing Event Hub Namespace 


// resource iothub_addroute 'Microsoft.Devices/IoTHubs' = {
//   name: 'HubwayTelemetryRoute'
//   parent: existing_iotHubName_resource
//   properties: {
//     condition: 'Hubway'
//     endpointNames: [
//       'HubwayTelemetry'
//     ]
//   }
// }


// Reference Existing resource
// resource existing_eventHubName 'Microsoft.EventHub/namespaces@2022-10-01-preview' existing = {
//   name: eventHubName
// }


// Setup Events Hubs Namespace?

// Setup Events Hubs Consumer Group?

// Setup IoT Hub Built In End Points
// Point to Event Hub
// Event Hub compatible endpoint


// Setup IoT Hub Message Routing
// Event Hubs Endpoint: HubwayTelemetryRoute
// Routing Query
// RoutingProperty = 'Hubway'

// 1. Add a Route
// 2. Endpoint Type = "Event Hubs"
// 3. Event Hub Namespaces = evh-3kqatjsvwshvq or eventHubName


