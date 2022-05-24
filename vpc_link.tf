resource "aws_security_group" "security_group" {
  count = local.include_vpc_link == true ? 1 : 0

  name        = "vpc-link-sg-${var.component}-${var.deployment_identifier}"
  description = "VPC link security group for: ${var.component}, deployment: ${var.deployment_identifier}"
  vpc_id      = local.vpc_id
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  count = local.include_vpc_link == true ? 1 : 0

  name               = "vpc-link-${var.component}-${var.deployment_identifier}"
  security_group_ids = [try(aws_security_group.security_group[0].id, "")]
  subnet_ids         = local.vpc_link_subnet_ids

  tags = local.tags
}
