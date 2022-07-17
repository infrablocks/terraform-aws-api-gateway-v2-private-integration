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
