terraform {
  backend "s3" {
    bucket     = "my-terraform-state-bucket"
    key        = "prod/terraform.tfstate"
    region     = "us-west-2"
    access_key = "AKIAIOSFODNN8EXAMPLE"
    secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYBLAHKEY"
  }
}
