resource "aws_iam_role" "lambda_role" {
  name        = "${local.prefix.value}-lambda-role"
  path        = "/${var.customer_name}/"
  description = "IAM Role for ${local.prefix.value} instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${local.prefix.value}-lambda-role"
  }
}

resource "aws_lambda_function" "lambda" {
  filename      = "modules/customer/resources/lambda.zip"
  function_name = "${local.prefix.value}-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "LambdaS3CrossAccountAccess.lambda_handler"

  source_code_hash = filebase64sha256("modules/customer/resources/lambda.zip")
  runtime          = "python3.7"

  environment {
    variables = {
      ACCESS_KEY  = "AKIAIOSFODNN7BLAAAH"
      SECRET_KEY  = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYBLAAHKEY"
      BUCKET_NAME = "my-logs-bucket"
      region      = "us-west-2"
    }
  }
}

resource "aws_lambda_alias" "lambda_alias" {
  name             = "${local.prefix.value}-lambda-alias"
  description      = "${local.prefix.value} Lambda Alias"
  function_name    = aws_lambda_function.lambda.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_permission" "allow" {
  statement_id  = "${local.prefix.value}-allow"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "*"
  qualifier     = aws_lambda_alias.lambda_alias.name
}
