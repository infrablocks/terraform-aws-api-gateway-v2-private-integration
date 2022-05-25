output "vpc_link_id" {
  value = try(aws_apigatewayv2_vpc_link.vpc_link[0].id, "")
}

output "vpc_link_default_security_group_id" {
  value = try(aws_security_group.vpc_link[0].id, "")
}
