variable "component" {
  description = "The component for which this API gateway private integration exists."
  type        = string
}
variable "deployment_identifier" {
  type        = string
  description = "An identifier for this instantiation."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC in which to create the VPC link for this private integration. Required when `include_vpc_link` and `include_vpc_link_security_group` are both `true`."
  default     = ""
}
variable "vpc_link_subnet_ids" {
  type        = list(string)
  description = "The subnet IDs in which to create the VPC link for this private integration. Required when `include_vpc_link` is `true`."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to set on created resources."
  default     = {}
}

variable "include_default_tags" {
  type        = bool
  description = "Whether or not to include default tags on created resources. Defaults to `true`."
  default     = true
}
variable "include_vpc_link" {
  type        = bool
  description = "Whether or not to create a VPC link for the private integration. Defaults to `true`."
  default     = true
}
