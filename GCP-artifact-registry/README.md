# Introduction

This is a script for deploying a container image repository on GCP, the specific service is called Artifact Registry for whatever reason. Basically, we need to have the image already stored on this repo before it can be deployed as a container within a node on GKE, for that use the script on the GKE directory.

## GCP Setup

Before executing the script the connection to the GCP account must be setup. First step is to install and configure gcloud CLI, follow the instructions here:

https://cloud.google.com/sdk/docs/install

Once that is complete, make sure the provider.tf file is properly configured for the project, region and zone we want to deploy our resources.

Next setup the IAM permissions required for terraform to deploy and update resources. To do this, setup a new "Service account" from GCP console, it should be in the "IAM and admin" menu. Make sure the service account has the necessary permission to deploy and update resources, the console walks you through this. For general purpose deployments, a "Basic Editor" role allows access for all types of resources. For a more production application it's advisable to limit this to a role that can only use the resources required in the project. From here, the rest of the configuration don't matter, give it whatever name. Once the service account is active use the "KEYS" tab to generate new keys, it should automatically download it.

Lastly, edit the provider.tf file for your use case, the "credentials" variable should be the file path to your credentials file that was downloaded. And the "project" is actually the Project ID, NOT the project name. If you use the name it just gives permission errors since that project doesn't exist. You can get the Project ID from the GCP console as well, it shows up on the project switching menu.

It is also not a bad idea to have gcloud properly setup and authenticated, the CLI can also utilize the same service account if needed. Follow the instructions here:

https://cloud.google.com/sdk/docs/authorizing

### terraform commands

Initializing the project config
`terraform init`

Planning out the changes it will make
`terraform plan`

Executing changes
`terraform apply`

Synchronize resource changes made from console
`terraform refresh`

Destroy resources defined in the main.tf file
`terraform destroy`
