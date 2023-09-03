param keyvaultName string
param azuremapname string
//param functionAppName string
// param secret_AzureWebJobsStorageName string
// param secret_WebsiteContentAzureFileConnectionStringName string
param appInsightsInstrumentationKey string
param appInsightsConnectionString string

param KeyVault_ClientIdName string

@secure()
param KeyVault_ClientIdValue string

param KeyVault_SubscriptionKeyName string

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

// Create KeyVault Secrets
resource secret1 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_ClientIdName
  parent: existing_keyvault
  properties: {
    value: KeyVault_ClientIdValue
  }
}

// Reference Existing resource
resource existing_azuremaps 'Microsoft.Maps/accounts@2021-12-01-preview' existing = {
  name: azuremapname
}
var AzureMapsSubscriptionKeyString = existing_azuremaps.listKeys().primaryKey

// Create KeyVault Secrets
resource secret2 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: KeyVault_SubscriptionKeyName
  parent: existing_keyvault
  properties: {
    value: AzureMapsSubscriptionKeyString
  }
}

