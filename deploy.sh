#!/bin/bash
set -e

resourceGroupName=debugging-container-events
acrName=debuggingeventsacr
logWorkspaceName=logworkspacedebugging
containerName=debuggingContainer

echo "> Create resource group"
az group create -n $resourceGroupName --location 'westeurope'

echo "> Setup ACR and log analytics workspace"
az deployment group create -g $resourceGroupName -f main.bicep --parameters acrName=$acrName logWorkspaceName=$logWorkspaceName

echo "> Build container"
az acr build -t debugging:latest -r $acrName .

echo "> Deploy container instance"
az deployment group create -g $resourceGroupName -f container-instance.bicep --parameters containerName=$containerName imageName=debugging acrName=$acrName logWorkspaceName=$logWorkspaceName
