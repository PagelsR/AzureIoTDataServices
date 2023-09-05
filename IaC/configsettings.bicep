param keyvaultName string

//param functionAppName string
// param secret_AzureWebJobsStorageName string
// param secret_WebsiteContentAzureFileConnectionStringName string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string

param KeyVault_MapsClientIdName string

@secure()
param KeyVault_MapsClientIdValue string

param KeyVault_MapsSubscriptionKeyName string

@secure()
param KeyVault_MapsSubscriptionKeyValue string

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

// // Create KeyVault Secrets
resource secret1 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_MapsClientIdName
  parent: existing_keyvault
  properties: {
    value: KeyVault_MapsClientIdValue
  }
}

// Create KeyVault Secrets
resource secret2 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_MapsSubscriptionKeyName
  parent: existing_keyvault
  properties: {
    value: KeyVault_MapsSubscriptionKeyValue
  }
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


