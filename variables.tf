variable "domain" {
  description = "the domain for this cf+s3 application"
}

variable "certdomain" {
  description = "the certificate"
  default     = ""
}

variable "region" {
  description = "the aws region to deploy to"
  default     = "eu-central-1"
}

variable "cloudfront_key_pair" {}

variable "encrypted_cloudfront_private_key" {}

variable "website_config" {
  type = "map"
}
