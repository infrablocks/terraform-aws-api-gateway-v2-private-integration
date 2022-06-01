resource "aws_apigatewayv2_route" "route" {
  for_each = local.route_map

  api_id    = var.api_id
  route_key = each.key

  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}
