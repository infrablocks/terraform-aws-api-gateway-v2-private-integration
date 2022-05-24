output "vpc_link_id" {
  value = try(aws_apigatewayv2_vpc_link.vpc_link[0].id, "")
}
