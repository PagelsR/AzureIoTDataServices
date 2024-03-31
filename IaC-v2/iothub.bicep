param location string = resourceGroup().location
param defaultTags object
param iotHubName string
//param appInsightsWorkspaceName string

@secure()
param EventHubPrimaryConnectionString string

// Define the IoT Hub
resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  tags: defaultTags
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 2
      }
    }
    routing: {
      routes: [
        {
          name: 'BostonHubwayTelemetryRoute'
          source: 'DeviceMessages'
          condition: 'RoutingProperty = \'Hubway\''
          endpointNames: [
            'HubwayTelemetryRoute'
          ]
          isEnabled: true
        }
      ]
      endpoints: {
        eventHubs: [
          {
            name: 'HubwayTelemetryRoute'
            connectionString: EventHubPrimaryConnectionString
          }
        ]
      }
      
    }
  }
}

//var iotSecuritySolutionName = 'appwIoT-${uniqueString(resourceGroup().id)}'

// resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
//   name: iotSecuritySolutionName
//   location: location
//   sku: {
//     name: 'PerGB2018'
//   }
//   properties: {
//     retentionInDays: 30
//   }
// }

// resource logAnalyticsWorkspaceIoT 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
//   name: iotSecuritySolutionName
//   location: location
//   properties:{
//     sku: {
//       name: 'PerGB2018'
//     }
//     retentionInDays: 30
//     features: {
//       searchVersion: 1
//       legacy: 0
//       enableLogAccessUsingOnlyResourcePermissions: true
//     }
//   }
// }

// // Log Analytics workspace for Application Insights
// resource existing_applicationInsightsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
//   name: appInsightsWorkspaceName
// }

// New IoT Security Solution resource - Defender for IoT
// resource iotSecuritySolution 'Microsoft.Security/iotSecuritySolutions@2019-08-01' = {
//   name: 'default'
//   location: location
//   properties: {
//     displayName: 'IoT Hub Security Solution'
//     iotHubs: [
//       iotHub.id
//     ]
//     workspace: logAnalyticsWorkspaceIoT.id
//   }
// }
