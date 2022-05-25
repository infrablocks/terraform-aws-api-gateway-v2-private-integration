output "vpc_id" {
  value = module.base_networking.vpc_id
}
output "private_subnet_ids" {
  value = module.base_networking.private_subnet_ids
}
output "api_id" {
  value = module.api_gateway.api_gateway_id
}
output "alb_arn" {
  value = module.application_load_balancer.arn
}
output "alb_listeners" {
  value = module.application_load_balancer.listeners
}
