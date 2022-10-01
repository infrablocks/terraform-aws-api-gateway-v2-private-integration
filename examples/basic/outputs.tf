output "private_subnet_ids" {
  value = module.base_networking.private_subnet_ids
}

output "api_id" {
  value = module.api_gateway.api_gateway_id
}

output "alb_listener_arn" {
  value = module.application_load_balancer.listeners["default"].arn
}

output "integration_id" {
  value = module.private_integration.integration_id
}

output "vpc_link_id" {
  value = module.private_integration.vpc_link_id
}

output "vpc_link_default_security_group_id" {
  value = module.private_integration.vpc_link_default_security_group_id
}

output "routes" {
  value = module.private_integration.routes
}
