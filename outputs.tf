output "integration_id" {
  value = aws_apigatewayv2_integration.integration.id
}

output "vpc_link_id" {
  value = try(aws_apigatewayv2_vpc_link.vpc_link[0].id, var.vpc_link_id)
}

output "vpc_link_default_security_group_id" {
  value = try(aws_security_group.vpc_link[0].id, "")
}

output "routes" {
  value = {for route in local.routes: route.route_key => aws_apigatewayv2_route.route[route.route_key].id }
}
