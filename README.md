### Intro ###

This repo is a collection of Terraform projects based around new tools and experiments I want to try out. Each directory in the root repo is a separate project and has it's own readme file.

These projects are not designed to utilize any custom or third party modules at the moment since they should all be small scale proof of concept projects, but the goal is to make the main.tf file 'neat' enough that the individual resources can be quickly turned into modules if needed.

I might also add some general TF and possibly openTF commands and instructions here as a sort of personal documentation.

## General TF commands ##

Initializing the project config
`terraform init`

Planning out the changes it will make
`terraform plan`

Executing changes
`terraform apply`

Destroy resources defined in the main.tf file
`terraform destroy`