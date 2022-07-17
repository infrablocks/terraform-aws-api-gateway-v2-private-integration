data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "private_integration" {
  # This makes absolutely no sense. I think there's a bug in terraform.
  source = "../../../../../../../.."

  component             = var.component
  deployment_identifier = var.deployment_identifier

  api_id                    = data.terraform_remote_state.prerequisites.outputs.api_id
  integration_uri           = data.terraform_remote_state.prerequisites.outputs.alb_listeners["default"].arn
  tls_server_name_to_verify = var.tls_server_name_to_verify

  routes = var.routes

  request_parameters = var.request_parameters

  vpc_id              = var.vpc_id
  vpc_link_id         = var.vpc_link_id
  vpc_link_subnet_ids = var.vpc_link_subnet_ids

  tags = var.tags

  include_default_tags                    = var.include_default_tags
  include_vpc_link                        = var.include_vpc_link
  include_vpc_link_default_security_group = var.include_vpc_link_default_security_group
  include_vpc_link_default_ingress_rule   = var.include_vpc_link_default_ingress_rule
  include_vpc_link_default_egress_rule    = var.include_vpc_link_default_egress_rule
  use_tls                                 = var.use_tls
}
