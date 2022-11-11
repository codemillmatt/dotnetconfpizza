param name string
param location string = resourceGroup().location
param tags object = {}

param menuSecretUri string
param checkoutSecretUri string
param signalRSecretUri string

param azureSignalRKeyName string
param cartUrlKeyName string
param checkoutDbKeyName string
param daprCheckoutApiKeyName string
param daprMenuApiKeyName string
param menuDbKeyName string
param menuUrlKeyName string

param cartUrlValue string
param daprCheckoutApiValue string
param daprMenuApiValue string
param menuUrlValue string


resource appConfig 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
}

resource signalRKeyVaultStore 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: azureSignalRKeyName
  properties: {
    value: string({ uri: signalRSecretUri })
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

resource menuDbKeyVaultStore 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: checkoutDbKeyName
  properties: {
    value: string({ uri: menuSecretUri })
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

resource checkoutDbKeyVaultStore 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: menuDbKeyName
  properties: {
    value: string({ uri: checkoutSecretUri })
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}

resource cartUrlStore 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: cartUrlKeyName
  properties: {
    value: cartUrlValue
  }
}

resource daprCheckoutApiStore 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: daprCheckoutApiKeyName
  properties: {
    value: daprCheckoutApiValue
  }
}

resource daprMenuApiStore 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: daprMenuApiKeyName
  properties: {
    value: daprMenuApiValue
  }
}

resource menuUrlStore 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
  parent: appConfig
  name: menuUrlKeyName
  properties: {
    value: menuUrlValue
  }
}



output appConfigName string = appConfig.name
output appConfigUrl string = appConfig.properties.endpoint
