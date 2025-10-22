/*
Connections enable your AI applications to access tools and objects managed elsewhere in or outside of Azure.

This example demonstrates how to add an Azure AI Search connection.
*/
param aiFoundryName string = '<your-account-name>'
param connectedResourceName string = 'ais-${aiFoundryName}'
param location string = 'westus'


// Whether to create a new Azure AI Search resource
@allowed([
  'new'
  'existing'
])
param newOrExisting string = 'new'
 
// Refers your existing Azure AI Foundry resource
resource aiFoundry 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' existing = {
  name: aiFoundryName
  scope: resourceGroup()
}

// Conditionally refers your existing Azure AI Search resource
resource existingAcaEnvironment 'Microsoft.App/managedEnvironments@2025-02-02-preview' existing = if (newOrExisting == 'existing') {
  name: connectedResourceName
}

// Conditionally creates a new Azure AI Search resource
resource newAcaEnvironment 'Microsoft.App/managedEnvironments@2025-02-02-preview' = if (newOrExisting == 'new') {
  name: connectedResourceName
  location: location
  properties: {}
}

// Creates the Azure Foundry connection to your Azure AI Search resource
resource connection 'Microsoft.CognitiveServices/accounts/connections@2025-10-01-preview' = {
  name: '${aiFoundryName}-acaenvironment'
  parent: aiFoundry
  properties: {
    category: 'AzureContainerAppEnvironment'
    authType: 'AAD' 
    isSharedToAll: true
    credentials: {}
    metadata: {
      ApiType: 'Azure'
      ResourceId: ((newOrExisting == 'new') ? newAcaEnvironment.id : existingAcaEnvironment.id)
    }
  }
}
