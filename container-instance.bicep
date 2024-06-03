param logWorkspaceName string
param acrName string
param containerName string
param imageName string

var registryServer = '${acrName}.azurecr.io'
var image = '${registryServer}/${imageName}:latest'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
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
        name: 'debugging-${imageName}'
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
        server: registryServer
        username: acrResource.listCredentials().username
        password: acrResource.listCredentials().passwords[0].value
      }
    ]
    diagnostics: {
      logAnalytics: {
        workspaceId: logWS.properties.customerId
        workspaceKey: logWS.listKeys().primarySharedKey
      }
    }
  }
}
