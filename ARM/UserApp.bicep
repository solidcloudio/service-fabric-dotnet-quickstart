@description('Name of your cluster - Between 3 and 23 characters. Letters and numbers only.')
param clusterName string = 'Cluster'

@description('The application type name.')
param applicationTypeName string = 'ApplicationType'

@description('The application type version.')
param applicationTypeVersion string = '1'

@description('The URL to the application package sfpkg file.')
param appPackageUrl string

@description('The name of the application resource.')
param applicationName string = 'Application1'

@description('The name of the service resource in the format of {applicationName}~{serviceName}.')
param serviceName string = 'Service1'

@description('The name of the service type.')
param serviceTypeName string = 'Service1Type'

@description('The name of the service resource in the format of {applicationName}~{serviceName}.')
param serviceName2 string = 'Service2'

@description('The name of the service type.')
param serviceTypeName2 string = 'Service2Type'

var clusterLocation = resourceGroup().location

resource clusterName_applicationType 'Microsoft.ServiceFabric/clusters/applicationTypes@2019-03-01' = {
  name: '${clusterName}/${applicationTypeName}'
  location: clusterLocation
  properties: {
    provisioningState: 'Default'
  }
  dependsOn: []
}

resource clusterName_applicationTypeName_applicationTypeVersion 'Microsoft.ServiceFabric/clusters/applicationTypes/versions@2019-03-01' = {
  parent: clusterName_applicationType
  name: applicationTypeVersion
  location: clusterLocation
  properties: {
    provisioningState: 'Default'
    appPackageUrl: appPackageUrl
  }
}

resource clusterName_application 'Microsoft.ServiceFabric/clusters/applications@2019-03-01' = {
  name: '${clusterName}/${applicationName}'
  location: clusterLocation
  properties: {
    provisioningState: 'Default'
    typeName: applicationTypeName
    typeVersion: applicationTypeVersion
    parameters: {
    }
    upgradePolicy: {
      upgradeReplicaSetCheckTimeout: '01:00:00.0'
      forceRestart: 'false'
      rollingUpgradeMonitoringPolicy: {
        healthCheckWaitDuration: '00:02:00.0'
        healthCheckStableDuration: '00:05:00.0'
        healthCheckRetryTimeout: '00:10:00.0'
        upgradeTimeout: '01:00:00.0'
        upgradeDomainTimeout: '00:20:00.0'
      }
      applicationHealthPolicy: {
        considerWarningAsError: 'false'
        maxPercentUnhealthyDeployedApplications: '50'
        defaultServiceTypeHealthPolicy: {
          maxPercentUnhealthyServices: '50'
          maxPercentUnhealthyPartitionsPerService: '50'
          maxPercentUnhealthyReplicasPerPartition: '50'
        }
      }
    }
  }
  dependsOn: [
    clusterName_applicationTypeName_applicationTypeVersion
  ]
}

resource clusterName_applicationName_service 'Microsoft.ServiceFabric/clusters/applications/services@2019-03-01' = {
  parent: clusterName_application
  name: serviceName
  location: clusterLocation
  properties: {
    provisioningState: 'Default'
    serviceKind: 'Stateless'
    serviceTypeName: serviceTypeName
    instanceCount: '-1'
    partitionDescription: {
      partitionScheme: 'Singleton'
    }
    serviceLoadMetrics: []
    servicePlacementPolicies: []
    defaultMoveCost: ''
  }
}

resource clusterName_applicationName_service2 'Microsoft.ServiceFabric/clusters/applications/services@2019-03-01' = {
  parent: clusterName_application
  name: serviceName2
  location: clusterLocation
  properties: {
    provisioningState: 'Default'
    serviceKind: 'Stateful'
    serviceTypeName: serviceTypeName2
    targetReplicaSetSize: '3'
    minReplicaSetSize: '2'
    replicaRestartWaitDuration: '00:01:00.0'
    quorumLossWaitDuration: '00:02:00.0'
    standByReplicaKeepDuration: '00:00:30.0'
    partitionDescription: {
      partitionScheme: 'UniformInt64Range'
      Count: '5'
      LowKey: '1'
      HighKey: '5'
    }
    hasPersistedState: 'true'
    correlationScheme: []
    serviceLoadMetrics: []
    servicePlacementPolicies: []
    defaultMoveCost: 'Low'
  }
}