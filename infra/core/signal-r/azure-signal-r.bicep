param name string
param location string = resourceGroup().location
param tags object = {}

param keyVaultName string

resource signalR 'Microsoft.SignalRService/signalR@2022-02-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Free_F1'
  }
  kind: 'SignalR'
  properties: {
    features: [
      {
        flag: 'ServiceMode'
        value: 'Serverless'
      }
    ]
  }
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource kvSecrets 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: 'AzureSignalRConnectionString'
  parent: kv
  properties: {
    value: listKeys(signalR.id, signalR.apiVersion).primaryConnectionString
  }
}

output signalRFullUrl string = signalR.properties.hostName
output signalRSecretUri string = kvSecrets.properties.secretUri
