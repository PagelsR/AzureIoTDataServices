param location string = resourceGroup().location
param defaultTags object
param iotHubName string
param iotTelemetryRouteName string
//param iotTelemetryRouteProperty string

@secure()
param EventHubPrimaryConnectionString string

// Define the IoT Hub
resource iotHub 'Microsoft.Devices/IotHubs@2023-06-30' = {
  name: iotHubName
  tags: defaultTags
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S1'
    capacity: 1
  }
  properties: {
    eventHubEndpoints: {
      events: {
        retentionTimeInDays: 1
        partitionCount: 4
      }
    }
    routing: {
      routes: [
        {
          name: iotTelemetryRouteName
          source: 'DeviceMessages'
          condition: 'RoutingProperty = \'OVfiets\''
          endpointNames: [
            iotTelemetryRouteName
          ]
          isEnabled: true
        }
      ]
      endpoints: {
        eventHubs: [
          {
            name: iotTelemetryRouteName
            connectionString: EventHubPrimaryConnectionString
          }
        ]
      }
      
    }
  }
}
