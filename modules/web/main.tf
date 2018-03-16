locals {
  s3_domain = "web.${var.domain}"
  s3_arn    = "arn:aws:s3:::${local.s3_domain}"
}
