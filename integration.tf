resource "aws_apigatewayv2_integration" "integration" {
  api_id = var.api_id

  description = "Private integration for component: ${var.component} and deployment identifier: ${var.deployment_identifier}."

  integration_type = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri = var.integration_uri

  connection_type = "VPC_LINK"
  connection_id = try(module.api_gateway_vpc_link[0].vpc_link_id, var.vpc_link_id)

  request_parameters = local.request_parameters_resolved

  dynamic "tls_config" {
    for_each = local.use_tls == true ? [var.tls_server_name_to_verify] : []
    content {
      server_name_to_verify = var.tls_server_name_to_verify
    }
  }
}
