resource "aws_apigatewayv2_integration" "integration" {
  api_id = var.api_id
  
  description = "Private integration for component: ${var.component} and deployment identifier: ${var.deployment_identifier}."

  integration_type = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri = var.integration_uri

  connection_type = "VPC_LINK"
  connection_id = try(aws_apigatewayv2_vpc_link.vpc_link[0].id, null)
}
