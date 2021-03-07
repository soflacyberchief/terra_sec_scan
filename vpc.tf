resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "${local.prefix.value}-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.prefix.value}-public-subnet-1"
  }

}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.64/26"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.prefix.value}-public-subnet-2"
  }

}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.0.128/26"
  availability_zone = var.availability_zone

  tags = {
    Name = "${local.prefix.value}-private-subnet-1"
  }

}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.0.192/26"
  availability_zone = var.availability_zone

  tags = {
    Name = "${local.prefix.value}-private-subnet-1"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.prefix.value}-igw"
  }
}

resource "aws_eip" "ngw_eip_1" {
  vpc = true
  tags = {
    Name = "${local.prefix.value}-ngw-eip-1"
  }
}

resource "aws_eip" "ngw_eip_2" {
  vpc = true
  tags = {
    Name = "${local.prefix.value}-ngw-eip-2"
  }
}

resource "aws_nat_gateway" "nat_gateway_1" {
  subnet_id     = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.ngw_eip_1.id

  tags = {
    Name = "${local.prefix.value}-nat-gateway-1"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  subnet_id     = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.ngw_eip_2.id

  tags = {
    Name = "${local.prefix.value}-nat-gateway-2"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.prefix.value}-public-rtb"
  }
}

resource "aws_route_table_association" "public_subnet1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public_subnet2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  timeouts {
    create = "3m"
  }
}

resource "aws_route_table" "private_rtb_1" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.prefix.value}-private-rtb-1"
  }
}

resource "aws_route_table" "private_rtb_2" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.prefix.value}-private-rtb-2"
  }
}

resource "aws_route_table_association" "private_subnet1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rtb_1.id
}

resource "aws_route_table_association" "private_subnet2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rtb_2.id
}

resource "aws_route" "nat_gateway_route1" {
  route_table_id         = aws_route_table.private_rtb_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_1.id

  timeouts {
    create = "3m"
  }
}

resource "aws_route" "nat_gateway_route2" {
  route_table_id         = aws_route_table.private_rtb_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_1.id

  timeouts {
    create = "3m"
  }
}

resource "aws_flow_log" "vpcflowlogs" {
  log_destination      = aws_s3_bucket.flowlogsbucket.arn
  log_destination_type = "s3"
  traffic_type         = "REJECT"
  vpc_id               = aws_vpc.vpc.id

  tags = {
    Name = "${local.prefix.value}-vpc-flowlogs"
  }
}

resource "aws_s3_bucket" "flowlogsbucket" {
  bucket        = "${local.prefix.value}-flowlogs-bucket"
  force_destroy = false

  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }

  grant {
    type        = "Group"
    permissions = ["READ", "WRITE"]
    uri         = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
  }

  tags = {
    Name = "${local.prefix.value}-vpc-flowlogs"
  }

}

resource "aws_s3_bucket_policy" "flowlogs_bucket_policy" {
  bucket = aws_s3_bucket.flowlogsbucket.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "AWSLogDeliveryWrite",
          "Effect" : "Allow",
          "Principal" : { "Service" : "delivery.logs.amazonaws.com" },
          "Action" : "s3:PutObject",
          "Resource" : [
            "arn:aws:s3:::${local.prefix.value}-flowlogs-bucket/flow-logs/AWSLogs/*",
          ],
          "Condition" : { "StringEquals" : { "s3:x-amz-acl" : "bucket-owner-full-control" } }
        },
        {
          "Sid" : "AWSLogDeliveryAclCheck",
          "Effect" : "Allow",
          "Principal" : { "Service" : "delivery.logs.amazonaws.com" },
          "Action" : "s3:GetBucketAcl",
          "Resource" : "arn:aws:s3:::log-bucket"
        }
      ]
    }
  )
}
