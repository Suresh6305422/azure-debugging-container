param logWorkspaceName saripalliws
param acrName saripalliacr
param containerName saripalliaci
param imageName nginx

var registryServer = 'saripalliacr.azurecr.io'
var image = 'saripalliacr.azurecr.io/nginx:latest'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: saripalliacr
  scope: resourceGroup()
}

resource logWS 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logWorkspaceName
  scope: resourceGroup()
}

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: containerName
  location: resourceGroup().location
  properties: {
    containers: [
      {
        name: 'nginx'
        properties: {
          image: image
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Never'
    imageRegistryCredentials: [
      {
        server: saripalliacr.azurecr.io
        username: Saripalliacr
        password: m7re3COGKpS5VOM46F/S4WsPKn5P9AhSCmVKWUPJTB+ACRD+Gw8R
      }
    ]
    diagnostics: {
      logAnalytics: { 
        logtype: 'ContainerInsights'
        workspaceId: logWS.properties.customerId
        workspaceKey: logWS.listKeys().primarySharedKey
      }
    }
  }
}
