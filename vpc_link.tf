module "api_gateway_vpc_link" {
  count = local.include_vpc_link == true ? 1 : 0

  source = "infrablocks/api-gateway-v2/aws//modules/vpc_link"
  version = "1.0.0"

  component = var.component
  deployment_identifier = var.deployment_identifier

  vpc_id = local.vpc_id
  vpc_link_subnet_ids = local.vpc_link_subnet_ids

  tags = var.tags

  include_default_tags = local.include_default_tags
  include_vpc_link_default_security_group = local.include_vpc_link_default_security_group
  include_vpc_link_default_ingress_rule = local.include_vpc_link_default_ingress_rule
  include_vpc_link_default_egress_rule = local.include_vpc_link_default_egress_rule
}
