param location string = resourceGroup().location
param tags object = {}
param environmentName string
param caeName string
param appConfigName string
param keyVaultName string
param containerRegistryName string
param imageName string

var serviceName = 'checkout'

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-06-01-preview' existing = {
  name: caeName
}

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2022-05-01' existing = {
  name: appConfigName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}

resource checkoutApi 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: '${environmentName}${serviceName}'
  location: location
  tags: union(tags, { 'azd-service-name': serviceName })
  identity: { type: 'SystemAssigned' }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
        transport: 'auto'
      }
      activeRevisionsMode: 'Single'
      dapr: {
        enabled: true
        appId: 'checkout-api'
      }
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          username: containerRegistry.name
          passwordSecretRef: 'registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          image: !empty(imageName) ? imageName : 'nginx:latest'
          name: 'pizzaconfcheckoutapi'
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Development'
            }
            {
              name: 'appConfigUrl'
              value: appConfig.properties.endpoint
            }
          ]
        }
      ]
    }
  }
}

resource keyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${keyVault.name}/add'
  properties: {
    accessPolicies: [
      {
        objectId: checkoutApi.identity.principalId
        permissions: {
          secrets: [ 
            'get'
            'list'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]
  }
}

resource appConfigAccessPolicies 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(checkoutApi.name, appConfig.name)
  scope: appConfig
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071')
    principalId: checkoutApi.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
