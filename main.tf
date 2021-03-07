provider "aws" {
  alias   = "ce_usw2"
  region  = var.region
  version = "~> 2.48"
  profile = var.ce_account_profile
}

module "customer1" {
  source        = "./modules/customer"
  customer_name = "customer1"
  region        = "us-west-2"

  providers = {
    aws = aws.ce_usw2
  }
}

module "customer2" {
  source        = "./modules/customer"
  customer_name = "customer2"
  region        = "us-west-2"

  providers = {
    aws = aws.ce_usw2
  }
}

output customer1_vpc_id {
  value = module.customer1.vpc_id
}

output customer1_instance_id {
  value = module.customer1.ec2_instance_id
}

output customer2_vpc_id {
  value = module.customer2.vpc_id
}

output customer2_instance_id {
  value = module.customer2.ec2_instance_id
}
