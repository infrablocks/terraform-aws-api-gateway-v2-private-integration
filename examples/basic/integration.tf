module "private_integration" {
  source = "../../"

  component             = var.component
  deployment_identifier = var.deployment_identifier

  api_id                    = module.api_gateway.api_gateway_id
  integration_uri           = module.application_load_balancer.listeners["default"].arn
  tls_server_name_to_verify = "https://service.example.com"

  routes = [{
    route_key: "GET /"
  }]

  vpc_id              = module.base_networking.vpc_id
  vpc_link_subnet_ids = module.base_networking.private_subnet_ids
}
