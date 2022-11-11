param environmentName string
param location string = resourceGroup().location
param tags object = {}

param applicationInsightsConnectionString string
param applicationInsightsInstrumentationKey string
param containerAppsEnvironmentName string
param containerRegistryName string
param external bool = false
param imageName string
param containerName string
param serviceName string
param targetPort int = 80
param appConfigUrl string
param daprAppId string

module app '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-shared-module'
  params: {
    name: '${environmentName}${serviceName}'
    location: location
    tags: union(tags, { 'azd-env-name': environmentName, 'azd-service-name': serviceName })
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerName: containerName
    containerRegistryName: containerRegistryName
    env: [
      {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Development'
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsightsConnectionString
      }
      {
        name: 'APPLICATIONINSIGHTS_INSTRUMENTATIONKEY'
        value: applicationInsightsInstrumentationKey
      }
      {
        name: 'ASPNETCORE_LOGGING__CONSOLE__DISABLECOLORS'
        value: 'true'
      }
      {
        name: 'appConfigUrl'
        value: appConfigUrl
      }
    ]
    external: external
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    targetPort: targetPort
    daprAppId: daprAppId
  }
}

output CONTAINER_APP_IDENTITY_PRINCIPAL_ID string = app.outputs.identityPrincipalId
output CONTAINER_APP_NAME string = app.outputs.name
output CONTAINER_APP_URI string = app.outputs.uri
output CONTAINER_APP_IMAGE_NAME string = app.outputs.imageName
