terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.14"
    }
    command = {
      source = "LukeCarrier/command"
      version = "0.2.0"
    }
  }
}
