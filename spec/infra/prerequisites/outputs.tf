#output "vpc_id" {
#  value = module.base_networking.vpc_id
#}
#output "private_subnet_ids" {
#  value = module.base_networking.private_subnet_ids
#}
#output "api_id" {
#  value = module.api_gateway.api_gateway_id
#}
#output "alb_arn" {
#  value = module.application_load_balancer.arn
#}
#output "alb_listeners" {
#  value = module.application_load_balancer.listeners
#}
#output "vpc_link_id" {
#  value = aws_apigatewayv2_vpc_link.vpc_link.id
#}
#output "vpc_link_security_group_id" {
#  value = aws_security_group.vpc_link.id
#}
