variable "domain" {
  description = "the domain for this cf+s3 application"
}

variable "certdomain" {
  description = "the certificate"
  default     = ""
}

variable "mx_hosts" {
  description = "MX DNS Records"
  type        = "list"
  default     = []
}

variable "region" {
  description = "the aws region to deploy to"
  default     = "eu-central-1"
}

variable "cloudfront_key_pair" {
  description = "the cloudfront private key ID from https://console.aws.amazon.com/iam/home?region=eu-central-1#/security_credential"
}

variable "encrypted_cloudfront_private_key" {}

variable "cloudfront_private_key_file" {
  description = "the cloudfront private key from https://console.aws.amazon.com/iam/home?region=eu-central-1#/security_credential"
}

variable "website_config" {
  description = "the website configuration"
  type        = "map"
}
