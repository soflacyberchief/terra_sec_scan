resource "aws_kms_key" "my_key" {
  description             = "${local.prefix.value}-kms-key"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.prefix.value}-kms-key"
  }
}

resource "aws_kms_alias" "my_alias" {
  name          = "alias/${local.prefix.value}-key-alias"
  target_key_id = aws_kms_key.my_key.key_id
}

