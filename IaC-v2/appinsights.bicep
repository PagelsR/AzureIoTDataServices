param location string = resourceGroup().location
param appInsightsName string
param appInsightsWorkspaceName string
param appInsightsAlertName string
param defaultTags object

// Log Analytics workspace for Application Insights
resource applicationInsightsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: appInsightsWorkspaceName
  location: location
  properties:{
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    features: {
      searchVersion: 1
      legacy: 0
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: defaultTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: applicationInsightsWorkspace.id
  }
}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: appInsightsAlertName
  location: 'global'
  properties: {
    description: 'Response time alert'
    severity: 0
    enabled: true
    scopes: [
      applicationInsights.id
      ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: '1st criterion'
          metricName: 'requests/duration'
          operator: 'GreaterThan'
          threshold: 300
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: emailActionGroup.id
      }
    ]
  }
}

resource emailActionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: 'ag--${uniqueString(resourceGroup().id)}' //'emailActionGroup'
  location: 'global'
  properties: {
    groupShortName: 'Randy Pagels'
    enabled: true
    emailReceivers: [
      {
        name: 'Randy Pagels'
        emailAddress: 'randy.pagels@xebia.com'
        useCommonAlertSchema: true
      }
    ]
  }
}

output out_appInsightsInstrumentationKey string = applicationInsights.properties.InstrumentationKey
output out_appInsightsConnectionString string = applicationInsights.properties.ConnectionString
