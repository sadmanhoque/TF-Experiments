### Introduction ###

This is a basic initial TF project to make sure all the configuration setup to connection with GCP is done properly and use that as a reference.

## GCP Setup

Before executing the script the connection to the GCP account must be setup. First step is to install and configure gcloud CLI, follow the instructions here:

https://cloud.google.com/sdk/docs/install

Once that is complete, make sure the provider.tf file is properly configured for the project, region and zone we want to deploy our resources.

Lastly, we need to run the command `gcloud auth application-default login` which enables Terraform to utilize the gcloud CLI connection to GCP in order to deploy the resources in out script.

## list of commands ##

Initializing the project config
`terraform init`

Planning out the changes it will make
`terraform plan`

Executing changes
`terraform apply`

Destroy resources defined in the main.tf file
`terraform destroy`