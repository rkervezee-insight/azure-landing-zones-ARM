
# Create the new project within a specific organization
az devops project create --name 'azOps' --organization 'https://dev.azure.com/insightaudemo/'

# Set the defaults for the local Azure Cli shell

az devops configure --defaults organization=https://dev.azure.com/insightaudemo/ project=azOps

# Import - Create a new repository from the upstream template repository

az repos import create --git-url https://github.com/Azure/AzOps-Accelerator --repository 'azOps'

#Pipelines - Create two new pipelines from existing YAML manifests

az pipelines create --name 'AzOps - Pull' --branch main --repository 'azOps' --repository-type tfsgit --yaml-path .pipelines/pull.yml

az pipelines create --name 'AzOps - Push' --branch main --repository 'azOps' --repository-type tfsgit --yaml-path .pipelines/push.yml

# Variables - Add secrets for authenticating pipelines with Azure Resource Manager

az pipelines variable create --name 'ARM_TENANT_ID' --pipeline-name 'AzOps - Pull' --secret false --value 'a2ebc691-c318-4ec2-998a-a87c528378e0'

az pipelines variable create --name 'ARM_SUBSCRIPTION_ID' --pipeline-name 'AzOps - Pull' --secret false --value '5cb7efe0-67af-4723-ab35-0f2b42a85839'

az pipelines variable create --name 'ARM_CLIENT_ID' --pipeline-name 'AzOps - Pull' --secret false --value '86db4f04-a5b7-4920-8a8d-5e0e4458ca89'

az pipelines variable create --name 'ARM_CLIENT_SECRET' --pipeline-name 'AzOps - Pull' --secret true --value '6d615a49-845a-4547-956b-7fddde8cb44b'

az pipelines variable create --name 'ARM_TENANT_ID' --pipeline-name 'AzOps - Push' --secret false --value 'a2ebc691-c318-4ec2-998a-a87c528378e0'

az pipelines variable create --name 'ARM_SUBSCRIPTION_ID' --pipeline-name 'AzOps - Push' --secret false --value '5cb7efe0-67af-4723-ab35-0f2b42a85839'

az pipelines variable create --name 'ARM_CLIENT_ID' --pipeline-name 'AzOps - Push' --secret false --value '86db4f04-a5b7-4920-8a8d-5e0e4458ca89'

az pipelines variable create --name 'ARM_CLIENT_SECRET' --pipeline-name 'AzOps - Push' --secret true --value '6d615a49-845a-4547-956b-7fddde8cb44b'

# Policy - Add build validation policy to push changes

az pipelines show --name 'AzOps - Push'

az repos policy build create --blocking true --branch main --display-name 'Push' --enabled true --build-definition-id azOps --repository-id azops --queue-on-source-update-only false --manual-queue-only false --valid-duration 0