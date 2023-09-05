// Deploy Azure infrastructure for FuncApp + monitoring

// Region for all resources
param location string = resourceGroup().location
param resourceGroupName string = resourceGroup().name
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

var iotHubName = 'iot-${uniqueString(resourceGroup().id)}'
//var iotContainerName = 'iotcontainer-${uniqueString(resourceGroup().id)}'
//var storageaccountName = 'stor${uniqueString(resourceGroup().id)}'
var eventHubName = 'evh-${uniqueString(resourceGroup().id)}'
var eventHubNamespaceName = 'evhns-${uniqueString(resourceGroup().id)}'
var cosmosDBName = 'cosmos-${uniqueString(resourceGroup().id)}'

// remove dashes for storage account name
//var storageAccountName = 'sta${uniqueString(resourceGroup().id)}'

// KeyVault Secret Names
//param secret_AzureWebJobsStorageName string = 'AzureWebJobsStorage'
param KeyVault_MapsClientIdName string = 'MapsClientId'
param KeyVault_MapsSubscriptionKeyName string = '<apsSubscriptionKey'

// Tags
var defaultTags = {
  App: 'Azure IoT Data Services'
  CostCenter: costCenter
  CreatedBy: createdBy
}

// Create IoT Hub
module iotHubmod './iothub4.bicep' = {
  name: 'iothubdeploy'
  params: {
    location: location
    iotHubName: iotHubName
    defaultTags: defaultTags
  }
  dependsOn:  [
    eventhubmod
  ]
}

// module iotHubmod './iothub2.bicep' = {
//     name: 'iothubdeploy'
//     params: {
//       location: location
//       iotHubName: iotHubName
//       defaultTags: defaultTags
//       resourceGroupName: resourceGroupName
//     }
//     dependsOn:  [
//       storageaccountmod
//       eventhubmod
//     ]
//   }

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
// module storageaccountmod './storageaccount.bicep' = {
//   name: 'storageaccountdeploy'
//   params: {
//     location: location
//     defaultTags: defaultTags
//     storageAccountName: storageAccountName
//   }
// }

// Create Application Insights
module appinsightsmod 'appinsights.bicep' = {
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
module functionappmod 'funcapp.bicep' = {
  name: 'functionappdeploy'
  params: {
    location: location
    functionAppServicePlanName: functionAppServicePlanName
    functionAppName: functionAppName
    defaultTags: defaultTags
    //storageAccountName: storageAccountName
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

 // ObjectId of alias RPagels
param AzObjectIdPagels string = '0aa95253-9e37-4af9-a63a-3b35ed78e98b'

// ObjectId of Service Principal "52a8e_ServicePrincipal_FullAccess"
param ADOServiceprincipalObjectId string = '1681488b-a0ee-4491-a254-728fe9e43d8c'

 // Create Configuration Entries
module configsettingsmod './configsettings.bicep' = {
  name: 'configSettings'
  params: {
    keyvaultName: keyvaultName
    KeyVault_MapsClientIdValue: azuremapsmod.outputs.out_AzureMapsClientId
    KeyVault_MapsClientIdName: KeyVault_MapsClientIdName
    tenant: subscription().tenantId
    KeyVault_MapsSubscriptionKeyName: KeyVault_MapsSubscriptionKeyName
    KeyVault_MapsSubscriptionKeyValue: azuremapsmod.outputs.out_AzureMapsprimaryKey
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
   ]
 }

// Output Params used for IaC deployment in pipeline
output out_azuremapname string = azuremapname
output out_functionAppName string = functionAppName
