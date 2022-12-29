Terraform AWS API Gateway V2 Private Integration
================================================

[![Version](https://img.shields.io/github/v/tag/infrablocks/terraform-aws-api-gateway-v2-private-integration?label=version&sort=semver)](https://github.com/infrablocks/terraform-aws-api-gateway-v2-private-integration/tags)
[![Build Pipeline](https://img.shields.io/circleci/build/github/infrablocks/terraform-aws-api-gateway-v2-private-integration/main?label=build-pipeline)](https://app.circleci.com/pipelines/github/infrablocks/terraform-aws-api-gateway-v2-private-integration?filter=all)
[![Maintainer](https://img.shields.io/badge/maintainer-go--atomic.io-red)](https://go-atomic.io)

A Terraform module for creating an API Gateway private integration using the
V2 API.

The private integration deployment requires:

* an existing API Gateway API
* an existing VPC containing the target component with which to integrate

The private integration deployment consists of:

* an API Gateway integration
* a set of API Gateway routes
* an optional VPC link

Usage
-----

To use the module, include something like the following in your Terraform
configuration:

```terraform
module "private_integration" {
  source  = "infrablocks/api-gateway-v2-private-integration/aws"
  version = "1.0.0"
  
  
}
```

See the
[Terraform registry entry](https://registry.terraform.io/modules/infrablocks/api-gateway-v2-private-integration/aws/latest)
for more details.

### Inputs

| Name                                      | Description                                                                                                                                                                   |              Default               |                                      Required                                       |
|-------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------:|:-----------------------------------------------------------------------------------:|
| `component`                               | The component for which this API gateway private integration exists.                                                                                                          |                 -                  |                                         Yes                                         |
| `deployment_identifier`                   | An identifier for this instantiation.                                                                                                                                         |                 -                  |                                         Yes                                         |
| `api_id`                                  | The ID of the API gateway API for which to create the integration.                                                                                                            |                 -                  |                                         Yes                                         |
| `integration_uri`                         | The integration URI to use for the private integration, typically the ARN of an Application Load Balancer listener, Network Load Balancer listener, or AWS Cloud Map service. |                 -                  |                                         Yes                                         |
| `tls_server_name_to_verify`               | The server name of the target to verify for TLS communication.                                                                                                                |                 -                  |                               If `use_tls` is `true`.                               |
| `routes`                                  | The routes to configure for this private integration.                                                                                                                         | `[{ route_key: "ANY /{proxy+}" }]` |                            If `include_routes` is `true`                            |
| `request_parameters`                      | The request parameters to configure for this private integration.                                                                                                             |                `[]`                |                                         No                                          |
| `vpc_id`                                  | The ID of the VPC in which to create the VPC link for this private integration.                                                                                               |                 -                  | If `include_vpc_link` and `include_vpc_link_default_security_group` are both `true` |
| `vpc_link_id`                             | The ID of a VPC link to use when creating the private integration.                                                                                                            |                 -                  |                          If `include_vpc_link` is `false`                           |
| `vpc_link_subnet_ids`                     | The subnet IDs in which to create the VPC link for this private integration.                                                                                                  |                `[]`                |                           If `include_vpc_link` is `true`                           |
| `vpc_link_default_ingress_cidrs`          | The CIDRs allowed access to the VPC via the VPC link when using the default ingress rule.                                                                                     |          `["0.0.0.0/0"]`           |                                         No                                          |
| `vpc_link_default_egress_cidrs`           | The CIDRs accessible within the VPC via the VPC link when using the default egress rule.                                                                                      |          `["0.0.0.0/0"]`           |                                         No                                          |
| `tags`                                    | Additional tags to set on created resources.                                                                                                                                  |                `{}`                |                                         No                                          |
| `include_default_tags`                    | Whether or not to include default tags on created resources.                                                                                                                  |               `true`               |                                         No                                          |
| `include_vpc_link`                        | Whether or not to create a VPC link for the private integration.                                                                                                              |               `true`               |                                         No                                          |
| `include_vpc_link_default_security_group` | Whether or not to create a default security group for the VPC link for the private integration.                                                                               |               `true`               |                                         No                                          |
| `include_vpc_link_default_ingress_rule`   | Whether or not to create the default ingress rule on the security group created for the VPC link.                                                                             |               `true`               |                                         No                                          |
| `include_vpc_link_default_egress_rule`    | Whether or not to create the default egress rule on the security group created for the VPC link.                                                                              |               `true`               |                                         No                                          |
| `use_tls`                                 | Whether or not to use TLS when communicating with the target of this integration.                                                                                             |               `true`               |                                         No                                          |

### Outputs

| Name                                 | Description                                                                                                                           |
|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| `integration_id`                     | The ID of the managed private integration.                                                                                            |
| `vpc_link_id`                        | Either the ID of the managed VPC link, if included, otherwise the provided VPC link ID.                                               |
| `vpc_link_default_security_group_id` | The ID of the default security group created for the managed VPC link. This is an empty string if the security group is not included. |
| `routes`                             | A map of the routes added to the private integration.                                                                                 |

### Compatibility

This module is compatible with Terraform versions greater than or equal to
Terraform 1.0 and Terraform AWS provider versions greater than or equal to 4.0.

Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed
on your development machine:

* Ruby (3.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv
* aws-vault

#### Mac OS X Setup

Installing the required tools is best managed by [homebrew](http://brew.sh).

To install homebrew:

```shell
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, to install the required tools:

```shell
# ruby
brew install rbenv
brew install ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
eval "$(rbenv init -)"
rbenv install 3.1.1
rbenv rehash
rbenv local 3.1.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# aws-vault
brew cask install

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

Running the build requires an AWS account and AWS credentials. You are free to
configure credentials however you like as long as an access key ID and secret
access key are available. These instructions utilise
[aws-vault](https://github.com/99designs/aws-vault) which makes credential
management easy and secure.

To run the full build, including unit and integration tests, execute:

```shell
aws-vault exec <profile> -- ./go
```

To run the unit tests, execute:

```shell
aws-vault exec <profile> -- ./go test:unit
```

To run the integration tests, execute:

```shell
aws-vault exec <profile> -- ./go test:integration
```

To provision the module prerequisites:

```shell
aws-vault exec <profile> -- ./go deployment:prerequisites:provision[<deployment_identifier>]
```

To provision the module contents:

```shell
aws-vault exec <profile> -- ./go deployment:root:provision[<deployment_identifier>]
```

To destroy the module contents:

```shell
aws-vault exec <profile> -- ./go deployment:root:destroy[<deployment_identifier>]
```

To destroy the module prerequisites:

```shell
aws-vault exec <profile> -- ./go deployment:prerequisites:destroy[<deployment_identifier>]
```

Configuration parameters can be overridden via environment variables. For
example, to run the unit tests with a seed of `"testing"`, execute:

```shell
SEED=testing aws-vault exec <profile> -- ./go test:unit
```

When a seed is provided via an environment variable, infrastructure will not be
destroyed at the end of test execution. This can be useful during development
to avoid lengthy provision and destroy cycles.

To subsequently destroy unit test infrastructure for a given seed:

```shell
FORCE_DESTROY=yes SEED=testing aws-vault exec <profile> -- ./go test:unit
```

### Common Tasks

#### Generating an SSH key pair

To generate an SSH key pair:

```shell
ssh-keygen -m PEM -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

#### Generating a self-signed certificate

To generate a self signed certificate:

```shell
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

To decrypt the resulting key:

```shell
openssl rsa -in key.pem -out ssl.key
```

#### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```shell
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```shell
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at
https://github.com/infrablocks/terraform-aws-api-gateway-v2-private-integration.
This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

License
-------

The library is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
