data "aws_availability_zones" "zones" {}

module "base_networking" {
  source  = "infrablocks/base-networking/aws"
  version = "4.0.0"

  region = var.region
  availability_zones = data.aws_availability_zones.zones.names

  component = var.component
  deployment_identifier = var.deployment_identifier

  vpc_cidr = "10.0.0.0/16"

  include_nat_gateways = "no"
  include_route53_zone_association = "no"
}
