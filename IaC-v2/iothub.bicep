param location string = resourceGroup().location
param defaultTags object
param iotHubName string
param appInsightsWorkspaceName string

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

// resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
//   name: workspaceName
//   location: location
//   sku: {
//     name: 'PerGB2018'
//   }
//   properties: {
//     retentionInDays: 30
//   }
// }

// Log Analytics workspace for Application Insights
resource existing_applicationInsightsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: appInsightsWorkspaceName
}

// New IoT Security Solution resource - Defender for IoT
resource iotSecuritySolution 'Microsoft.Security/iotSecuritySolutions@2021-02-01' = {
  name: 'default'
  location: location
  properties: {
    displayName: 'IoT Hub Security Solution'
    iotHubs: [
      iotHub.id
    ]
    workspace: existing_applicationInsightsWorkspace.id
  }
}
