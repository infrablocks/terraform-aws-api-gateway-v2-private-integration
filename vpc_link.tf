resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  count = local.vpc_link_count

  name               = "vpc-link-${var.component}-${var.deployment_identifier}"
  security_group_ids = compact([try(aws_security_group.vpc_link[0].id, null)])
  subnet_ids         = local.vpc_link_subnet_ids

  tags = local.tags
}
