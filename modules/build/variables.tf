variable "region" {}
variable "domain" {}

variable "website_config" {
  type = "map"
}

variable "processed_bucket_arn" {}
variable "kms_key_arn" {}
variable "source_bucket_id" {}
variable "web_bucket_id" {}
variable "source_bucket_arn" {}
variable "web_bucket_arn" {}
variable "cloudfront_arn" {}
variable "build_bucket_id" {}
