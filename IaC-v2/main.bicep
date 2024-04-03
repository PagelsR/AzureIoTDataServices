// Deploy Azure infrastructure for FuncApp + monitoring

// Region for all resources
param location string = resourceGroup().location
var iotHubName = 'iot-${uniqueString(resourceGroup().id)}'
var iotDeviceName = 'iot-raspberrypi-${uniqueString(resourceGroup().id)}'
var eventHubName = 'hubwaytelemetry'
var eventHubNamespaceName = 'evhns-${uniqueString(resourceGroup().id)}'

param createdBy string = 'Randy Pagels'
param costCenter string = '74f644d3e665'

// Variables for Recommended abbreviations for Azure resource types
// https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
var appInsightsName = 'appi-${uniqueString(resourceGroup().id)}'
var appInsightsWorkspaceName = 'appw-${uniqueString(resourceGroup().id)}'
var appInsightsAlertName = 'responsetime-${uniqueString(resourceGroup().id)}'
var azuremapname = 'maps-${uniqueString(resourceGroup().id)}'
var functionAppName = 'func-${uniqueString(resourceGroup().id)}'
var functionAppServicePlanName = 'funcplan-${uniqueString(resourceGroup().id)}'
var keyvaultName = 'kv-${uniqueString(resourceGroup().id)}'
var cosmosDBName = 'cosmos-${uniqueString(resourceGroup().id)}'

// remove dashes for storage account name
var storageAccountNameFuncApp = 'sta${uniqueString(resourceGroup().id)}'
var storageAccountNameBlob = 'stablob${uniqueString(resourceGroup().id)}'

// KeyVault Secret Names
// Note: Underscores Not allowed in KeyVault
param KeyVault_MapsClientIdName string = 'MapsClientId'
param KeyVault_MapsSubscriptionKeyName string = 'MapsSubscriptionKey'
param KeyVault_AzureWebJobsStorageName string = 'AzureWebJobsStorage'
param KeyVault_WebsiteContentAzureFileConnectionString string = 'WebsiteContentAzureFileConnectionString'
param KeyVault_Shared_Access_Key_EVENTHUBName string = 'SharedAccessKeyEVENTHUB'
param KeyVault_Shared_Access_Key_DOCUMENTDBName string = 'SharedAccessKeyDOCUMENTDB'
param KeyVault_Azure_Maps_Subscription_KeyName string = 'AzureMapsSubscriptionKey'

// Tags
var defaultTags = {
  App: 'Azure IoT Data Services'
  CostCenter: costCenter
  CreatedBy: createdBy
}

// Create Event Hub Namespace
module eventhubmod './eventhub.bicep' = {
  name: 'eventhubnamespacedeploy'
  params: {
    location: location
    defaultTags: defaultTags
    eventHubName: eventHubName
    eventHubNamespaceName: eventHubNamespaceName
  }
}

// Create IoT Hub
module iotHubmod './iothub.bicep' = {
  name: 'iothubdeploy'
  params: {
    location: location
    iotHubName: iotHubName
    defaultTags: defaultTags
    EventHubPrimaryConnectionString: eventhubmod.outputs.out_eventHubPrimaryConnectionString
  }
  dependsOn:  [
    eventhubmod
  ]
}

// Create Application Insights
module appinsightsmod './appinsights.bicep' = {
  name: 'appinsightsdeploy'
  params: {
    location: location
    appInsightsName: appInsightsName
    defaultTags: defaultTags
    appInsightsAlertName: appInsightsAlertName
    appInsightsWorkspaceName: appInsightsWorkspaceName
  }
}

// Create Function App
module functionappmod './funcapp.bicep' = {
  name: 'functionappdeploy'
  params: {
    location: location
    functionAppServicePlanName: functionAppServicePlanName
    functionAppName: functionAppName
    defaultTags: defaultTags
    storageAccountNameFuncApp: storageAccountNameFuncApp
  }
  dependsOn:  [
    appinsightsmod
  ]
}

// Create Azure KeyVault
module keyvaultmod './keyvault.bicep' = {
  name: keyvaultName
  params: {
    location: location
    vaultName: keyvaultName
    }
 }

 module azuremapsmod './azuremaps.bicep' = {
  name: azuremapname
  params: {
    location: location
    azuremapname: azuremapname
  }
 }

 // Create CosmosDB
module cosmosdbmod './cosmosdb.bicep' = {
  name: 'cosmosdbdeploy'
  params: {
    location: location
    defaultTags: defaultTags
    cosmosDBName: cosmosDBName
  }
}

// Create Storage Account
module storageaccountmod './storageaccount.bicep' = {
  name: 'storageaccountdeploy'
  params: {
    location: location
    defaultTags: defaultTags
    storageAccountNameBlob: storageAccountNameBlob

  }
  dependsOn:  [
    eventhubmod
  ]
}

 // ObjectId of alias RPagels
param AzObjectIdPagels string = '0aa95253-9e37-4af9-a63a-3b35ed78e98b'

// ObjectId of Service Principal "52a8e_ServicePrincipal_FullAccess"
param ADOServiceprincipalObjectId string = '1681488b-a0ee-4491-a254-728fe9e43d8c'

 // Create Configuration Entries
 module configsettingsmod './configsettings.bicep' = {
  name: 'configSettings'
  params: {
    keyvaultName: keyvaultName
    functionAppName: functionAppName
    tenant: subscription().tenantId
    KeyVault_MapsSubscriptionKeyName: KeyVault_MapsSubscriptionKeyName
    KeyVault_ClientIdName: KeyVault_MapsClientIdName
    KeyVault_ClientIdValue: azuremapsmod.outputs.out_AzureMapsClientId
    KeyVault_Shared_Access_Key_EVENTHUBName: KeyVault_Shared_Access_Key_EVENTHUBName
    KeyVault_Shared_Access_Key_EVENTHUBValue: eventhubmod.outputs.out_eventHubPrimaryConnectionString
    KeyVault_Shared_Access_Key_DOCUMENTDBName: KeyVault_Shared_Access_Key_DOCUMENTDBName
    KeyVault_Shared_Access_Key_DOCUMENTDBValue: cosmosdbmod.outputs.out_CosmosDBConnectionString
    KeyVault_AzureWebJobsStorageName: KeyVault_AzureWebJobsStorageName
    KeyVault_WebsiteContentAzureFileConnectionStringName: KeyVault_WebsiteContentAzureFileConnectionString
    KeyVault_AzureWebJobsStorageValue: functionappmod.outputs.out_AzureWebJobsStorageFuncApp
    KeyVault_Azure_Maps_Subscription_KeyName: KeyVault_Azure_Maps_Subscription_KeyName
    KeyVault_Azure_Maps_Subscription_KeyValue: azuremapsmod.outputs.out_AzureMapsSubscriptionKeyString
    azuremapname: azuremapname
    funcAppServiceprincipalId: functionappmod.outputs.out_funcAppServiceprincipalId
    appInsightsInstrumentationKey: appinsightsmod.outputs.out_appInsightsInstrumentationKey
    appInsightsConnectionString: appinsightsmod.outputs.out_appInsightsConnectionString
    ADOServiceprincipalObjectId: ADOServiceprincipalObjectId
    AzObjectIdPagels: AzObjectIdPagels
    }
    dependsOn:  [
     keyvaultmod
     functionappmod
     azuremapsmod
     storageaccountmod
   ]
 }

// Output Params used for IaC deployment in pipeline
output out_azuremapname string = azuremapname
output out_keyvaultName string = keyvaultName
output out_functionAppName string = functionAppName
output out_iotHubName string = iotHubName
output out_iotdeviceName string = iotDeviceName
output out_eventHubPrimaryConnectionString string = eventhubmod.outputs.out_eventHubPrimaryConnectionString
