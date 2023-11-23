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

## Pushing images to the repo

To authenticate gcloud cli to the repo:

`gcloud auth configure-docker us-central1-docker.pkg.dev`

This seemingly unnecessarily complicated documentation that Google came up with instead of providing the commands on console like ECR:

https://cloud.google.com/artifact-registry/docs/docker/pushing-and-pulling

To summarize what the above instructions says, we do the following steps:

### Docker Build

First build the image with a specific tag, for example
`docker build --tag latest .`

### Docker Tag

Using the tag we used the last time as a reference, run this docker tag command:
`docker tag latest us-central1-docker.pkg.dev/gcp-devops-376520/my-repository/latest-image`

Where
* region = us-central1
* project-id = gcp-devops-376520
* repo name = my-repository
* image name on gcp = latest-image

### Push the image to artifact registry

For this run the following command:
`docker push us-central1-docker.pkg.dev/gcp-devops-376520/my-repository/latest-image`

Where
* region = us-central1
* project-id = gcp-devops-376520
* repo name = my-repository
* image name on gcp = latest-image 

## Pushing to Artifact Registry for production

Pushing to the repo requires the gcloud cli to be authenticated, here it works because ours has already been setup using the service account access keys which gives unlimited access to uploaded images to the repo. In a production environment this is not recommended, we should be using temporary access keys instead. For instructions to set that up follow the instructions here:

https://cloud.google.com/artifact-registry/docs/docker/authentication#linux-macos

## terraform commands

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
