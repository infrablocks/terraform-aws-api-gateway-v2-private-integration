variable "component" {
  description = "The component for which this API gateway private integration exists."
  type        = string
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "api_id" {
  description = "The ID of the API gateway API for which to create the integration."
  type        = string
}
variable "integration_uri" {
  description = "The integration URI to use for the private integration, typically the ARN of an Application Load Balancer listener, Network Load Balancer listener, or AWS Cloud Map service."
  type        = string
}
variable "tls_server_name_to_verify" {
  description = "The server name of the target to verify for TLS communication. Only required when `use_tls` is `true`."
  type        = string
  default     = null
}

variable "routes" {
  description = "The routes to configure for this private integration. Required when `include_routes` is `true`. Defaults to a single route with key \"ANY /{proxy+}\"."
  type        = list(object({
    route_key: string
  }))
  default     = [{
    route_key: "ANY /{proxy+}"
  }]
}

variable "request_parameters" {
  description = "The request parameters to configure for this private integration."
  type = list(object({
    parameter: string,
    type: string,
    value: string
  }))
  default = []
}

# Needs tests
variable "vpc_id" {
  description = "The ID of the VPC in which to create the VPC link for this private integration. Required when `include_vpc_link` and `include_vpc_link_default_security_group` are both `true`."
  type        = string
  default     = null
}
variable "vpc_link_id" {
  description = "The ID of a VPC link to use when creating the private integration. Only required if `include_vpc_link` is `false`."
  type        = string
  default     = null
}
variable "vpc_link_subnet_ids" {
  description = "The subnet IDs in which to create the VPC link for this private integration. Required when `include_vpc_link` is `true`."
  type        = list(string)
  default     = []
}
# Needs tests
variable "vpc_link_default_ingress_cidrs" {
  description = "The CIDRs allowed access to the VPC via the VPC link when using the default ingress rule."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
# Needs tests
variable "vpc_link_default_egress_cidrs" {
  description = "The CIDRs accessible within the VPC via the VPC link when using the default egress rule."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional tags to set on created resources."
  type        = map(string)
  default     = {}
}

variable "include_default_tags" {
  description = "Whether or not to include default tags on created resources. Defaults to `true`."
  type        = bool
  default     = true
}
variable "include_vpc_link" {
  description = "Whether or not to create a VPC link for the private integration. Defaults to `true`."
  type        = bool
  default     = true
}
variable "include_vpc_link_default_security_group" {
  description = "Whether or not to create a default security group for the VPC link for the private integration. Defaults to `true`."
  type        = bool
  default     = true
}
variable "include_vpc_link_default_ingress_rule" {
  description = "Whether or not to create the default ingress rule on the security group created for the VPC link. Defaults to `true`."
  type        = bool
  default     = true
}
variable "include_vpc_link_default_egress_rule" {
  description = "Whether or not to create the default egress rule on the security group created for the VPC link. Defaults to `true`."
  type        = bool
  default     = true
}
variable "use_tls" {
  description = "Whether or not to use TLS when communicating with the target of this integration. Defaults to `true`."
  type        = bool
  default     = true
}
