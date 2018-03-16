variable "domain" {}
variable "origin-access-identity-arn" {}
variable "kms_key_id" {}
variable "kms_key_name" {}
variable "kms_key_arn" {}
variable "encrypted_cloudfront_private_key" {}
variable "cloudfront_key_pair" {}
variable "source_bucket_arn" {}
variable "build_bucket_id" {}
variable "source_bucket_name" {}

variable "transcoder_region" {
  default = "eu-west-1"
}
