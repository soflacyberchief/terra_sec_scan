resource "aws_iam_role" "instance_role" {
  name                 = "${local.prefix.value}-role"
  path                 = "/${var.customer_name}/"
  description          = "IAM Role for ${local.prefix.value} instance"
  max_session_duration = 43200

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${local.prefix.value}-role"
  }

}

resource "aws_iam_role_policy" "role_policy" {
  name = "${local.prefix.value}-role-policy"
  role = aws_iam_role.instance_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:*",
          "ec2:*",
          "rds:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_user" "user" {
  name          = "${local.prefix.value}-user"
  force_destroy = true

  tags = {
    Name = "${local.prefix.value}-user"
  }

}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "user_policy" {
  name = "user_policy"
  user = aws_iam_user.user.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "userPolicyStatementID1",
        "Effect" : "Deny",
        "NotAction" : "iam:*",
        "Resource" : "*",
        "Condition" : { "NumericGreaterThanEquals" : { "aws:MultiFactorAuthAge" : "3600" } }
      },
      {
        "Sid" : "userPolicyStatementID1",
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "kms:*"
        ],
        "Resource" : "*",
        "Condition" : { "IpAddress" : { "aws:SourceIp" : ["64.40.11.1/32", "54.78.120.1/24"] } }
      }
    ]
    }
  )

}





