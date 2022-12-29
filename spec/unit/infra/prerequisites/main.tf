data "aws_availability_zones" "zones" {}

module "base_networking" {
  source  = "infrablocks/base-networking/aws"
  version = "5.0.0"

  region             = var.region
  availability_zones = data.aws_availability_zones.zones.names

  component             = var.component
  deployment_identifier = var.deployment_identifier

  vpc_cidr = "10.0.0.0/16"

  include_nat_gateways             = "no"
  include_route53_zone_association = "no"
}

module "api_gateway" {
  source  = "infrablocks/api-gateway-v2/aws"
  version = "1.0.0"

  component             = var.component
  deployment_identifier = var.deployment_identifier

  include_default_stage_domain_name = false

  providers = {
    aws     = aws
    aws.dns = aws
  }
}

module "application_load_balancer" {
  source  = "infrablocks/application-load-balancer/aws"
  version = "4.0.0"

  region     = var.region
  vpc_id     = module.base_networking.vpc_id
  subnet_ids = module.base_networking.private_subnet_ids

  component             = var.component
  deployment_identifier = var.deployment_identifier

  security_groups = {
    default = {
      associate    = "yes"
      ingress_rule = {
        include = "yes"
        cidrs   = ["0.0.0.0/0"]
      },
      egress_rule = {
        include   = "yes"
        from_port = 0
        to_port   = 65535
        cidrs     = ["0.0.0.0/0"]
      }
    }
  }

  target_groups = [
    {
      key                  = "default"
      port                 = 80
      protocol             = "HTTP"
      target_type          = "instance"
      deregistration_delay = 300
      health_check         = {
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        interval            = 30
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    }
  ]

  listeners = [
    {
      key             = "default"
      port            = "80"
      protocol        = "HTTP"
      certificate_arn = null,
      ssl_policy      = null,
      default_action  = {
        type             = "forward"
        target_group_key = "default"
      }
    }
  ]
}

resource "aws_security_group" "vpc_link" {
  name        = "provided-vpc-link-sg-${var.component}-${var.deployment_identifier}"
  description = "Provided VPC link security group for: ${var.component}, deployment: ${var.deployment_identifier}"
  vpc_id      = module.base_networking.vpc_id
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "provided-vpc-link-${var.component}-${var.deployment_identifier}"
  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = module.base_networking.private_subnet_ids
}
