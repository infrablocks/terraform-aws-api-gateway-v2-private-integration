variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "vpc_id" {
  type    = string
  default = null
}
variable "vpc_link_subnet_ids" {
  type    = list(string)
  default = null
}

variable "tags" {
  type    = map(string)
  default = null
}

variable "include_default_tags" {
  type    = bool
  default = null
}
variable "include_vpc_link" {
  type    = bool
  default = null
}
