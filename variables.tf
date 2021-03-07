variable "region" {
  description = "AWS region where the customer needs to be deployed"
  default     = "us-west-2"
}

//Customer Account AWS Profile
variable "ce_account_profile" {
  description = "AWS Profile name for Customer Environment"
}
