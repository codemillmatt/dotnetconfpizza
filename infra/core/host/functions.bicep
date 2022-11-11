param functionAppServicePlanName string
param functionAppName string
param location string = resourceGroup().location
param tags object = {}

param appInsightsName string
param storageAccountName string

param trackingUrlKeyName string

param appConfigName string
param keyVaultName string

var functionRuntime = 'dotnet'

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2022-05-01' existing = {
  name: appConfigName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-04-01-preview' existing = {
  name: keyVaultName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  kind: 'Storage'
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: functionAppServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'Y1'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  tags: union(tags, {
    'azd-service-name': 'tracker'
  })
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionRuntime
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
        }
        {
          name: 'ASPNETCORE_HOSTINGSTARTUPASSEMBLIES'
          value: 'Microsoft.Azure.SignalR'
        }
        {
          name: 'Azure__SignalR__StickyServerMode'
          value: 'Required'
        }
        {
          name: 'appConfigUrl'
          value: appConfig.properties.endpoint
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }
    httpsOnly: true
  }
}

// give the function app access to key vault
resource functionAppKeyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        tenantId: keyVault.properties.tenantId
        objectId: functionApp.identity.principalId
        permissions: {
          secrets: [
            'get','list'
          ]
        }
      }
    ]
  }
}

// give the funciton app read access to app configuration
resource functionAppAppConfigAccess 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.name, appConfig.name)
  scope: appConfig
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// add the function app's URL to app configuration
resource trackingUrlStore 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: trackingUrlKeyName
  properties: {
    value: functionApp.properties.defaultHostName
  }
}

output functionAppUrl string = functionApp.properties.defaultHostName
