variable "component" {
  description = "The component for which this API gateway private integration exists."
  type        = string
}
variable "deployment_identifier" {
  type        = string
  description = "An identifier for this instantiation."
}

variable "api_id" {
  type        = string
  description = "The ID of the API gateway API for which to create the integration."
}
variable "integration_uri" {
  type        = string
  description = "The integration URI to use for the private integration, typically the ARN of an Application Load Balancer listener, Network Load Balancer listener, or AWS Cloud Map service."
}
variable "tls_server_name_to_verify" {
  type        = string
  description = "The server name of the target to verify for TLS communication. Only required when `use_tls` is `true`."
  default     = null
}

variable "routes" {
  type        = list(object({
    route_key: string
  }))
  description = "The routes to configure for this private integration. Required when `include_routes` is `true`. Defaults to a single route with key \"ANY /{proxy+}\"."
  default     = [{
    route_key: "ANY /{proxy+}"
  }]
}

variable "request_parameters" {
  type = list(object({
    parameter: string,
    type: string,
    value: string
  }))
  default = []
}

# Needs tests
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC in which to create the VPC link for this private integration. Required when `include_vpc_link` and `include_vpc_link_default_security_group` are both `true`."
  default     = null
}
variable "vpc_link_id" {
  type        = string
  description = "The ID of a VPC link to use when creating the private integration. Only required if `include_vpc_link` is `false`."
  default     = null
}
variable "vpc_link_subnet_ids" {
  type        = list(string)
  description = "The subnet IDs in which to create the VPC link for this private integration. Required when `include_vpc_link` is `true`."
  default     = []
}
# Needs tests
variable "vpc_link_default_ingress_cidrs" {
  type        = list(string)
  description = "The CIDRs allowed access to the VPC via the VPC link when using the default ingress rule."
  default     = ["0.0.0.0/0"]
}
# Needs tests
variable "vpc_link_default_egress_cidrs" {
  type        = list(string)
  description = "The CIDRs accessible within the VPC via the VPC link when using the default egress rule."
  default     = ["0.0.0.0/0"]
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
variable "include_vpc_link_default_security_group" {
  type        = bool
  description = "Whether or not to create a default security group for the VPC link for the private integration. Defaults to `true`."
  default     = true
}
variable "include_vpc_link_default_ingress_rule" {
  type        = bool
  description = "Whether or not to create the default ingress rule on the security group created for the VPC link. Defaults to `true`."
  default     = true
}
variable "include_vpc_link_default_egress_rule" {
  type        = bool
  description = "Whether or not to create the default egress rule on the security group created for the VPC link. Defaults to `true`."
  default     = true
}
variable "use_tls" {
  type        = bool
  description = "Whether or not to use TLS when communicating with the target of this integration. Defaults to `true`."
  default     = true
}
