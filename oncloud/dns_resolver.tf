resource "aws_route53_resolver_endpoint" "cloud" {
  name      = "cloud-resolver"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.dns_resolver.id
  ]

  ip_address {
    subnet_id = aws_subnet.private_a.id
  }

  ip_address {
    subnet_id = aws_subnet.private_b.id
  }

  tags = {
    "Name" = "Cloud DNS Resolver"
  }
}

resource "aws_route53_resolver_endpoint" "premise" {
  name      = "premise-resolver"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.dns_resolver.id
  ]

  ip_address {
    subnet_id = aws_subnet.private_a.id
  }

  ip_address {
    subnet_id = aws_subnet.private_b.id
  }

  tags = {
    "Name" = "Premise DNS Resolver"
  }
}

output "cloud_resolvers" {
  value = aws_route53_resolver_endpoint.cloud.ip_address
}

output "premise_resolvers" {
  value = aws_route53_resolver_endpoint.premise.ip_address
}

resource "aws_route53_resolver_rule" "premise" {
  domain_name          = "premise.internal"
  name                 = "premise"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.premise.id

  target_ip {
    ip = "10.20.2.33"
  }

  tags = {
    "Name" = "Premise DNS"
  }
}

resource "aws_route53_resolver_rule_association" "premise_ra" {
  name             = "premise"
  vpc_id           = aws_vpc.cloud.id
  resolver_rule_id = aws_route53_resolver_rule.premise.id
}