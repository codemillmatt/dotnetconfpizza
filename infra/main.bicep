targetScope = 'subscription'

@minLength(1)
@maxLength(50)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@description('The Azure principal id of the user or process running the install')
param azurePrincipalId string

@minLength(1)
@description('Primary location for all resources')
param location string


param storageAccountName string = ''
param profileName string = ''
param endpointName string = ''
param storageContainers array = [
    { name: 'pizzaimages', publicAccess: 'Blob' } 
]

param sqlServerName string = ''
param checkoutDbName string = 'pizzacart'
param menuDbName string = 'pizzamenu'

param sqlAdminLogin string = ''
@secure()
param sqlAdminPassword string = newGuid()

param signalRName string = ''
param keyVaultName string = ''
param appConfigName string = ''

// These are the key names for the Azure App Configuration. Unless you're planning on updating the web APIs, leave these as is
param appConfigSignalRKeyName string = 'AzureSignalRConnectionString'
param appConfigCartUrlKeyName string = 'cartUrl'
param appConfigCheckoutDbKeyName string = 'CheckoutDb'
param appConfigDaprCheckoutApiKeyName string = 'DaprAppId:PizzaConf:CheckoutApi'
param appConfigDaprCheckoutApiValue string = 'checkoutapi'
param appConfigDaprMenuApiKeyName string = 'DaprAppId:PizzaConf:MenuApi'
param appConfigDaprMenuApiValue string = 'menuapi'
param appConfigMenuDbKeyName string = 'menuDb'
param appConfigMenuUrlKeyName string = 'menuUrl'
param appConfigTrackingUrlKeyName string = 'trackingUrl'

param functionAppName string = ''
param functionAppPlanName string = ''

param applicationInsightsDashboardName string = ''
param applicationInsightsName string = ''
param containerAppsEnvironmentName string = ''
param containerRegistryName string = ''
param logAnalyticsName string = ''

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }
var abbrs = loadJsonContent('abbreviations.json')

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
    name: '${abbrs.resourcesResourceGroups}${environmentName}'
    location: location
    tags: tags
}

// First create the key vault
module keyVault './core/key-vault/key-vault.bicep' = {
    name: 'keyvault'
    scope: rg
    params: {
        name: !empty(keyVaultName) ? keyVaultName : '${abbrs.keyVaultVaults}${resourceToken}'
        location: location
        tags: tags
        azurePrincipalId: azurePrincipalId
    }
}

// Storage for website images
module storage './core/storage/storage-account.bicep' = {
    name: 'storage'
    scope: rg
    params: {
        name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
        location: location
        tags: tags
        containers: storageContainers
    }
}

// CDN endpoint for website images
module cdn './core/cdn/endpoint.bicep' = {
    name: 'cdn'
    scope: rg
    params: {
        profileName: !empty(profileName) ? profileName : '${abbrs.cdnProfiles}${resourceToken}'
        endpointName: !empty(endpointName) ? endpointName : '${abbrs.cdnProfilesEndpoints}${resourceToken}'
        storageAccountHostName: replace(replace(storage.outputs.primaryEndpoints.blob, 'https://', ''), '/', '')
        location: location
        tags: tags
    }
}

module sql './core/sql-server/sql-azure.bicep' = {
    name: 'sql'
    scope: rg
    params: {
        location: location
        sqlServerName: !empty(sqlServerName) ? sqlServerName : '${abbrs.sqlServers}${resourceToken}'
        checkoutDbName: checkoutDbName
        menuDbName: menuDbName
        sqlServerAdminLogin: !empty(sqlAdminLogin) ? sqlAdminLogin : 'thepizzaman'
        sqlServerAdminPassword: sqlAdminPassword
        keyVaultName: keyVault.outputs.keyVaultName
    }
}

module signalr './core/signal-r/azure-signal-r.bicep' = {
    name: 'signalr'
    scope: rg
    params: {
        name: !empty(signalRName) ? signalRName : '${abbrs.signalRServiceSignalR}${resourceToken}'
        location: location
        tags: tags
        keyVaultName: keyVault.outputs.keyVaultName
    }
}

module appConfig './core/app-config/azure-app-config.bicep' = {
    name: 'appconfig'
    scope: rg
    params: {
        name: !empty(appConfigName) ? appConfigName : '${abbrs.appConfigurationConfigurationStores}${resourceToken}'
        location: location
        tags: tags
        azureSignalRKeyName: appConfigSignalRKeyName
        cartUrlKeyName: appConfigCartUrlKeyName
        cartUrlValue: 'http://localhost:3500'
        checkoutDbKeyName: appConfigCheckoutDbKeyName
        checkoutSecretUri: sql.outputs. checkoutDbSecretUri
        daprCheckoutApiKeyName: appConfigDaprCheckoutApiKeyName
        daprCheckoutApiValue: appConfigDaprCheckoutApiValue
        daprMenuApiKeyName: appConfigDaprMenuApiKeyName
        daprMenuApiValue: appConfigDaprMenuApiValue
        menuDbKeyName: appConfigMenuDbKeyName
        menuSecretUri: sql.outputs.mencuDbSecretUri
        menuUrlKeyName: appConfigMenuUrlKeyName
        menuUrlValue: 'http://localhost:3500'
        signalRSecretUri: signalr.outputs.signalRSecretUri
    }
}

module functions './core/host/functions.bicep' = {
    name: 'functions'
    scope: rg
    params: {
        location: location
        tags: tags
        appInsightsName: '${abbrs.insightsComponents}${resourceToken}'
        functionAppName: !empty(functionAppName) ? functionAppName : '${abbrs.webSitesFunctions}${resourceToken}'
        functionAppServicePlanName: !empty(functionAppPlanName) ? functionAppPlanName : '${abbrs.webSitesAppService}${resourceToken}'
        storageAccountName: '${abbrs.storageStorageAccounts}fn${resourceToken}'
        appConfigName: appConfig.outputs.appConfigName
        keyVaultName: keyVault.outputs.keyVaultName
        trackingUrlKeyName: appConfigTrackingUrlKeyName
    }
}

// Container apps host (including container registry)
module containerApps './core/host/container-apps.bicep' = {
    name: 'container-apps'
    scope: rg
    params: {
        name: 'app'
        containerAppsEnvironmentName: !empty(containerAppsEnvironmentName) ? containerAppsEnvironmentName : '${abbrs.appManagedEnvironments}${resourceToken}'
        containerRegistryName: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
        location: location
        logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
    }
}

// // Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
    name: 'monitoring'
    scope: rg
    params: {
        location: location
        tags: tags
        logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
        applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}ace${resourceToken}'
        applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
    }
}

output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output APPLICATIONINSIGHTS_INSTRUMENTATIONKEY string = monitoring.outputs.applicationInsightsInstrumentationKey
output APPLICATIONINSIGHTS_NAME string = monitoring.outputs.applicationInsightsName
output AZURE_CONTAINER_ENVIRONMENT_NAME string = containerApps.outputs.environmentName
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerApps.outputs.registryLoginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerApps.outputs.registryName

output AZURE_LOCATION string = location
output AZURE_STORAGE_ACCOUNT_NAME string = storage.outputs.name
output AZURE_CDN_HOST_NAME string = cdn.outputs.hostName
output AZURE_TENANT_ID string = tenant().tenantId
output SQL_SERVER_URL string = sql.outputs.sqlServerUrl
output SQL_ADMIN string = sql.outputs.sqlAdmin
output SIGNALR_URL string = signalr.outputs.signalRFullUrl
output APP_CONFIG_URL string = appConfig.outputs.appConfigUrl
