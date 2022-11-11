param name string
param location string = resourceGroup().location
param tags object = {}

param caeName string
param appConfigName string
param keyVaultName string
param containerRegistryName string
param imageName string

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

resource menuApi 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': 'menu' })
  identity: { type: 'SystemAssigned' }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      dapr: {
        enabled: true
        appId: 'menu-api'
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
          name: 'pizzaconfmenuapi'
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
        objectId: menuApi.identity.principalId
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
