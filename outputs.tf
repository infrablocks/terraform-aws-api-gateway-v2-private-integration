output "integration_id" {
  value = aws_apigatewayv2_integration.integration.id
}

output "vpc_link_id" {
  value = try(module.api_gateway_vpc_link[0].vpc_link_id, var.vpc_link_id)
}

output "vpc_link_default_security_group_id" {
  value = try(module.api_gateway_vpc_link[0].vpc_link_default_security_group_id, "")
}

output "routes" {
  value = {for route in local.routes: route.route_key => aws_apigatewayv2_route.route[route.route_key].id }
}
