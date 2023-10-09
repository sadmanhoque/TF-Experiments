provider "aws" {
    region = "ca-central-1"
    //shared_config_files      = ["/c/Users/sadma/.aws/config"]
    shared_credentials_files = ["/Users/sadma/.aws/credentials"]
    profile = "default"
}
