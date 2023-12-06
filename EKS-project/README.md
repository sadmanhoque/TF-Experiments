### Introduction ###

This is a TF project based on deploying a working EKS cluster, it is primarily based on the documentation here:
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

The goal is to utilize this script to deploy a functional full stack web application.

kubernetes-manifest file documentation:

https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#progress-deadline-seconds

Configure locally installed kubectl to connect with the deployed cluster

`aws eks --region ca-central-1 update-kubeconfig --name my-eks-cluster`

If kubectl is already configured for other clusters run:

`kubectl config use-context <eks-cluster-name>`

The precise cluster name needs to be retrieved from the list of clusters on on kubectl configuration, to get that run:

`kubectl config get-contexts`

To authenticate local kubectl with AWS so it can actually deployer worker nodes:

`aws eks update-kubeconfig --region ca-central-1 --name my-eks-cluster`
For more documentation on the process https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html


To deploy the worker node now run

`kubectl apply -f test-k8s-manifest.yaml`

To setup the ingress for the worker node

`kubectl apply -f k8s-ingress-manifest.yaml`

Now wait for the changes to be executed, use the console to figure out when it's done.

After that run

## list of commands ##

Initializing the project config
`terraform init`

Planning out the changes it will make
`terraform plan`

Executing changes
`terraform apply`

Destroy resources defined in the main.tf file
`terraform destroy`