locals {
  # default for cases when `null` value provided, meaning "use default"
  vpc_id                                  = var.vpc_id == null ? "" : var.vpc_id
  vpc_link_subnet_ids                     = var.vpc_link_subnet_ids == null ? [] : var.vpc_link_subnet_ids
  vpc_link_default_ingress_cidrs          = var.vpc_link_default_ingress_cidrs == null ? ["0.0.0.0/0"] : var.vpc_link_default_ingress_cidrs
  vpc_link_default_egress_cidrs           = var.vpc_link_default_egress_cidrs == null ? ["0.0.0.0/0"] : var.vpc_link_default_egress_cidrs
  include_default_tags                    = var.include_default_tags == null ? true : var.include_default_tags
  include_vpc_link                        = var.include_vpc_link == null ? true : var.include_vpc_link
  include_vpc_link_default_security_group = var.include_vpc_link_default_security_group == null ? true : var.include_vpc_link_default_security_group
  include_vpc_link_default_ingress_rule   = var.include_vpc_link_default_ingress_rule == null ? true : var.include_vpc_link_default_ingress_rule
  include_vpc_link_default_egress_rule    = var.include_vpc_link_default_egress_rule == null ? true : var.include_vpc_link_default_egress_rule

  include_vpc_link_default_security_group_resolved = local.include_vpc_link == true && local.include_vpc_link_default_security_group == true
  include_vpc_link_default_ingress_rule_resolved   = local.include_vpc_link_default_security_group_resolved == true && local.include_vpc_link_default_ingress_rule == true
  include_vpc_link_default_egress_rule_resolved    = local.include_vpc_link_default_security_group_resolved == true && local.include_vpc_link_default_egress_rule == true

  vpc_link_count                        = local.include_vpc_link == true ? 1 : 0
  vpc_link_default_security_group_count = local.include_vpc_link_default_security_group_resolved ? 1 : 0
  vpc_link_default_ingress_rule_count   = local.include_vpc_link_default_ingress_rule_resolved == true ? 1 : 0
  vpc_link_default_egress_rule_count    = local.include_vpc_link_default_egress_rule_resolved == true ? 1 : 0

  default_tags = local.include_default_tags == true ? {
    Component            = var.component
    DeploymentIdentifier = var.deployment_identifier
  } : {}
  tags = merge(local.default_tags, var.tags)
}
