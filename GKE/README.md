### Introduction ###

This is a script for deploying a fully functional Kubernetes based server on Google cloud, the specific service on GCP called Google Kubernetes Engine (GKE).

## GCP Setup

Before executing the script the connection to the GCP account must be setup. First step is to install and configure gcloud CLI, follow the instructions here:

https://cloud.google.com/sdk/docs/install

Once that is complete, make sure the provider.tf file is properly configured for the project, region and zone we want to deploy our resources.

Next setup the IAM permissions required for terraform to deploy and update resources. To do this, setup a new "Service account" from GCP console, it should be in the "IAM and admin" menu. Make sure the service account has the necessary permission to deploy and update resources, the console walks you through this. For general purpose deployments, a "Basic Editor" role allows access for all types of resources. For a more production application it's advisable to limit this to a role that can only use the resources required in the project. From here, the rest of the configuration don't matter, give it whatever name. Once the service account is active use the "KEYS" tab to generate new keys, it should automatically download it.

Lastly, edit the provider.tf file for your use case, the "credentials" variable should be the file path to your credentials file that was downloaded. And the "project" is actually the Project ID, NOT the project name. If you use the name it just gives permission errors since that project doesn't exist. You can get the Project ID from the GCP console as well, it shows up on the project switching menu.

It is also not a bad idea to have gcloud properly setup and authenticated, the CLI can also utilize the same service account if needed. Follow the instructions here:

https://cloud.google.com/sdk/docs/authorizing

## Deploying an application to a node within the cluster

### Container Image

The first step is to get the image of the application we want to deploy to the worker node onto GCP. The recommended process for this is to use Googke Artifact Registry, sort of like GCP's version of Docker Hub if you will. The setup script and upload instructions are all in the GCP-artifact-registry directory.

### Deploying worker nodes

Kubectl should already be installed into the local machine, if not, google for the instructions.

Once that's done, kubectl must be configured to deploy to the newly created cluster, for this project it can be done using this command:

`gcloud container clusters get-credentials test-gke --region us-central1`

Where `test-gke` is the name of the cluster and `us-central1` is the region.

We need a configuration file commonly called Kubernetes Manifest which defines the node we will be deploying, an example is within this dir. Once the file is created, run the command:

`kubectl apply -f example-kubernetes-manifest.yaml`

So far we have only deployed the application to a kubernetes node, but it doesn't have any point of ingress for access. To 'expose' the GKE workload run the following command"

`kubectl expose deployment react-app --type=LoadBalancer --port=3000 --target-port=3000`

Where:
* react-app = name of the deployed workload, this is defined in the example-kubernetes-manifest.yaml file
* LoadBalancer = the type of ingress management service used, here on GCP and for this application the most suitable service is a load balancer, it may differ based on the type of application hosted.
* port and target-port should be self explanatory, they are the port used to access the application, will differ based on how the application and its dockerfile are configured.

After running that command we have a external IP address to access the application from, in production we would now configure a CDN service or the domain configuration to route our domain to this IP, this repo is only for experiments so that part is not here.

To find out what the fixed IP is it can be either found on GCP console by going to the Kubernetes Engine resource menu, then Workload menu, and if we select the deployed workload and scroll to the bottom the IP is shown in the 'expose' section of the configuration. The other way, and I haven't tested this one myself but it probably works, is to run this command and check the 'external-IP' column.

`kubectl get services`

## Taking down the deployment

Due to the delete protection configuration on Kubernetes it is possible that Terraform won't be able to delete the cluster using the destroy command. In this case, go to console and delete the cluster manually. However, this puts TF out of sync with what's actually deployed. To fix this run the following command: `terraform refresh`. This script deployed more than just the script, so it is best to run the destroy command again afterwards.

# terraform commands 

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

### NOTES

## Deployment

One of the key aspects of deploying an application to any kubernetes clusters is the kubernetes-manifest file, it's similar to a dockerfile as in it dictates the configuration of the pod we are deploying the container in. 

It is possible to utilize a terraform script for this instead but I did not find enough resources for that and in theory the manifest file should be the same across any kubernetes cluster regardless of the platform they are deployed to, again, this theory needs to be tested.

If using GCP, a quick way to figure out what should be in the kubernetes-manifest for the application we want to deploy is to do it manually. Upload the image to artifact-registry, deploy the cluster using terraform, then instead of running the kubectl command deploy a new workload manually from console. Google has walthroughs and good documentation on this process. Once the workload is deployed with proper ingress configuration and we can confirm that the site is accessible using the IP, there's a tab or button on the main page of the workload we have just deployed, it's called "YAML" or something similar. That is our kubernetes-manifest, all I did was copy whatever was there and used it as the example-kubernetes-manifest.yaml file.

## TODO
* implement logging