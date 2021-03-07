resource "aws_route53_zone" "mydomain" {
  name = "mydomain.com"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "mydomain.com"
  validation_method = "DNS"

  tags = {
    Environment = "${local.prefix.value}-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "mydomain_records" {
  allow_overwrite = true
  name            = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  records         = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl             = 60
  type            = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id         = aws_route53_zone.mydomain.zone_id
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.mydomain_records.fqdn]

  timeouts {
    create = "60m"
  }
}
