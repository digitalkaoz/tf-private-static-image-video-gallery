provider local {
  version = "~> 1.1"
}

provider "null" {
  version = "~> 1.0"
}

provider "archive" {
  version = "~> 1.0"
}

provider "aws" {
  region  = "eu-central-1"
  profile = "default"
  version = "~> 1.8"
}

provider "aws" {
  alias   = "west"
  region  = "us-east-1"
  profile = "default"
  version = "~> 1.8"
}

provider "aws" {
  alias   = "${var.transcoder_region}"
  region  = "${var.transcoder_region}"
  profile = "default"
  version = "~> 1.8"
}

data "aws_caller_identity" "current" {}

locals {
  s3_domain = "processed.${var.domain}"
  s3_arn    = "arn:aws:s3:::${local.s3_domain}"
}
