### Introduction ###

This is a TF project based on deploying a working EKS cluster, it is primarily based on the documentation here:
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster

The goal is to utilize this script to deploy a functional full stack web application.

## list of commands ##

Initializing the project config
`terraform init`

Planning out the changes it will make
`terraform plan`

Executing changes
`terraform apply`

Destroy resources defined in the main.tf file
`terraform destroy`