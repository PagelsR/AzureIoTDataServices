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

// remove dashes for storage account name
var storageAccountName = 'sta${uniqueString(resourceGroup().id)}'

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
    storageAccountName: storageAccountName
  }
  dependsOn:  [
    appinsightsmod
  ]
}

// // Create Storage Account
// module storageaccountmod './storageaccount.bicep' = {
//   name: 'storageaccountdeploy'
//   params: {
//     //location: location
//     //defaultTags: defaultTags
//     storageAccountName: storageAccountName
//   }
//   dependsOn:  [
//     eventhubmod
//   ]
// }


 // ObjectId of alias RPagels
param AzObjectIdPagels string = '0aa95253-9e37-4af9-a63a-3b35ed78e98b'

// ObjectId of Service Principal "52a8e_ServicePrincipal_FullAccess"
param ADOServiceprincipalObjectId string = '1681488b-a0ee-4491-a254-728fe9e43d8c'


// Output Params used for IaC deployment in pipeline
// output out_azuremapname string = azuremapname
// output out_functionAppName string = functionAppName
output out_iotHubName string = iotHubName
output out_iotdeviceName string = iotDeviceName
output out_eventHubPrimaryConnectionString string = eventhubmod.outputs.out_eventHubPrimaryConnectionString
