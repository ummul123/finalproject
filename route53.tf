# ACM Certificate with automated DNS validation
resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "ummul-project.apparelcorner.shop"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# Auto-create validation records in Route53
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  zone_id         = "Z01465681A54L4R5MBHUP" # Your hosted zone ID
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.record]
}

# Wait for validation to complete
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.ssl_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# ALB Alias record (auto-updates)
resource "aws_route53_record" "web_app" {
  zone_id = "Z01465681A54L4R5MBHUP"
  name    = "ummul-project.apparelcorner.shop"
  type    = "A"

  alias {
    name                   = aws_lb.web_app.dns_name
    zone_id                = aws_lb.web_app.zone_id
    evaluate_target_health = true # Checks if ALB is healthy
  }
}