output "integration_id" {
  description = "The ID of the managed private integration."
  value       = aws_apigatewayv2_integration.integration.id
}

output "vpc_link_id" {
  description = "Either the ID of the managed VPC link, if included, otherwise the provided VPC link ID."
  value       = try(module.api_gateway_vpc_link[0].vpc_link_id, var.vpc_link_id)
}

output "vpc_link_default_security_group_id" {
  description = "The ID of the default security group created for the managed VPC link.This is an empty string if the security group is not included."
  value       = try(module.api_gateway_vpc_link[0].vpc_link_default_security_group_id, "")
}

output "routes" {
  description = "A map of the routes added to the private integration."
  value       = {for route in local.routes : route.route_key => aws_apigatewayv2_route.route[route.route_key].id}
}
