resource "aws_security_group" "vpc_link" {
  count = local.vpc_link_default_security_group_count

  name        = "vpc-link-sg-${var.component}-${var.deployment_identifier}"
  description = "VPC link security group for: ${var.component}, deployment: ${var.deployment_identifier}"
  vpc_id      = local.vpc_id

  tags = local.tags
}

resource "aws_security_group_rule" "vpc_link_ingress" {
  count = local.vpc_link_default_security_group_count

  security_group_id = try(aws_security_group.vpc_link[0].id, null)

  type = "ingress"

  cidr_blocks = ["0.0.0.0/0"]

  protocol = "tcp"
  from_port = 443
  to_port = 443
}

resource "aws_security_group_rule" "vpc_link_egress" {
  count = local.vpc_link_default_security_group_count

  security_group_id = try(aws_security_group.vpc_link[0].id, null)

  type = "egress"

  cidr_blocks = ["0.0.0.0/0"]

  protocol = "all"
  from_port = -1
  to_port = -1
}
