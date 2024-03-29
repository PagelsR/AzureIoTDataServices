param azuremapname string
param location string = resourceGroup().location

resource azuremaps 'Microsoft.Maps/accounts@2023-06-01' = {
  name: azuremapname
  location: location
  sku: {
    name: 'G2'
  }
  kind: 'Gen2'
  identity: {
    type: 'None'
  }
  properties: {
    disableLocalAuth: false
    cors: {
      corsRules: [
        {
          allowedOrigins: []
        }
      ]
    }
  }
}

var AzureMapsSubscriptionKeyString = azuremaps.listKeys().primaryKey

output out_AzureMapsSubscriptionKeyString string = AzureMapsSubscriptionKeyString
output out_AzureMapsAppKey string = azuremaps.id
output out_AzureMapsClientId string = azuremaps.properties.uniqueId
