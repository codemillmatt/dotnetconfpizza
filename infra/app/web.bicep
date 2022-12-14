param location string = resourceGroup().location
param environmentName string
param tags object = {}

param caeName string
param appConfigName string
param keyVaultName string
param containerRegistryName string
param imageName string

var serviceName = 'web'

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

resource web 'Microsoft.App/containerApps@2022-06-01-preview' = {
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
        appId: 'web'
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
          name: 'pizzaconfweb'
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
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        objectId: web.identity.principalId
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

resource appConfigReader 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '516239f1-63e1-4d78-a4de-a74fb236a071'
  scope: subscription()
}

resource appConfigAccessPolicies 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(web.name, appConfig.name)
  scope: appConfig
  properties: {
    roleDefinitionId: appConfigReader.id
    principalId: web.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
