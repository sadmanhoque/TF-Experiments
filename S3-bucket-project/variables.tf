variable "bucket_name" {
  description = "(Required) Creates a unique bucket name"
  type        = string
  default     = "sadman-test-bucket"
}

variable "region" {
  description = "The region where the bucket is deployed"
  type        = string
  default     = "ca-central-1"
}