output "lambda_arn" {
  value = aws_lambda_function.lambda.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "lambda_role" {
  value = aws_iam_role.lambda_role.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "kms_key_arn" {
  value = aws_kms_key.my_key.arn
}

output "kms_key_alias_arn" {
  value = aws_kms_alias.my_alias.arn
}

output "instance_role_arn" {
  value = aws_iam_role.instance_role.arn
}

output "user_role_arn" {
  value = aws_iam_user.user.arn
}

output "user_access_key" {
  value = aws_iam_access_key.user.id
}

output "user_secret_access_key" {
  value = aws_iam_access_key.user.secret
}

output "db_instance_arn" {
  value = aws_db_instance.db_instance.arn
}

output "db_subnet_group" {
  value = aws_db_subnet_group.db_subnet_group.arn
}

output "zone_id" {
  value = aws_route53_zone.mydomain.zone_id
}

output "dns_record" {
  value = aws_route53_record.mydomain_records.fqdn
}

output "cert_domain_name" {
  value = aws_acm_certificate.cert.domain_name
}

output "customer_bucket_arn" {
  value = aws_s3_bucket.customer_bucket.arn
}

output "flowlogs_bucket_arn" {
  value = aws_s3_bucket.flowlogsbucket.arn
}

output "default_securitygroup_id" {
  value = aws_security_group.default_sg.id
}

output "database_securitygroup_id" {
  value = aws_security_group.db_sg.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnetid_1" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnetid_2" {
  value = aws_subnet.private_subnet_2.id
}

output "public_subnetid_1" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnetid_2" {
  value = aws_subnet.public_subnet_2.id
}

output "ec2_instance_id" {
  value = aws_instance.ec2_instance.id
}

output "alb_address" {
  value = aws_lb.alb.dns_name
}
