param sqlServerName string
param checkoutDbName string
param menuDbName string
param location string = resourceGroup().location
param tags object = {}

param keyVaultName string

param sqlServerAdminLogin string
@secure()
param sqlServerAdminPassword string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  properties: {
    administratorLogin: sqlServerAdminLogin
    administratorLoginPassword: sqlServerAdminPassword
  }

  resource firewallRules 'firewallRules' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      endIpAddress: '0.0.0.0'
      startIpAddress: '0.0.0.0'
    }
  }
}

resource checkoutDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: checkoutDbName
  parent: sqlServer
  location: location
  tags: tags
  sku: {
    name: 'GP_S_Gen5_1'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    autoPauseDelay: 60
    minCapacity: 1
  }
}

var checkoutConnectionString = 'Data Source=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${checkoutDbName};User ID=${sqlServerAdminLogin}@${sqlServer.name};Password=${sqlServerAdminPassword}'

resource menuDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: menuDbName
  parent: sqlServer
  location: location
  tags: tags
  sku: {
    name: 'GP_S_Gen5_1'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    autoPauseDelay: 60
    minCapacity: 1
  }
}

var menuConnectionString = 'Data Source=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${menuDbName};User ID=${sqlServerAdminLogin};Password=${sqlServerAdminPassword}'

// set the connection strings into key vault
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource checkoutKvSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${checkoutDbName}ConnectionString'
  parent: kv
  properties: {
    value: checkoutConnectionString
  }
}

resource menuKvSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: '${menuDbName}ConnectionString'
  parent: kv
  properties: {
    value: menuConnectionString
  }
}

output sqlServerName string = sqlServer.name
output sqlServerUrl string = sqlServer.properties.fullyQualifiedDomainName
output sqlAdmin string = sqlServerAdminLogin
output checkoutDbSecretUri string = checkoutKvSecret.properties.secretUri
output mencuDbSecretUri string = menuKvSecret.properties.secretUri
