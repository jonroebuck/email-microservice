trigger:
- main

pool:
  vmImage: 'ubuntu-latest'

variables:
  imageName: 'email-microservice'

steps:
- task: UsePythonVersion@0
  inputs:
    versionSpec: '3.x'
    addToPath: true

- script: |
    docker build -t $(imageName) .
  displayName: 'Build Docker image'

- script: |
    echo $(DOCKERHUB_PASSWORD) | docker login -u $(DOCKERHUB_USERNAME) --password-stdin
    docker tag $(imageName) $(DOCKERHUB_USERNAME)/$(imageName):latest
    docker push $(DOCKERHUB_USERNAME)/$(imageName):latest
  displayName: 'Push Docker image to Docker Hub'
  env:
    DOCKERHUB_USERNAME: $(DOCKERHUB_USERNAME)
    DOCKERHUB_PASSWORD: $(DOCKERHUB_PASSWORD)

- task: AzureRmWebAppDeployment@4
  inputs:
    azureSubscription: '<Azure subscription connection>'
    appName: '<Web App name>'
    package: '$(Pipeline.Workspace)/drop/$(imageName)'
    dockerImageTag: '$(DOCKERHUB_USERNAME)/$(imageName):latest'
