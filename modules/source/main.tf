locals {
  s3_domain = "source.${var.domain}"
  s3_arn    = "arn:aws:s3:::${local.s3_domain}"

  images = [".jpg", ".JPG", ".jpeg", ".JPEG", ".png", ".PNG"]
  videos = [".mp4", ".MP4", ".mov", ".MOV"]
}

data "aws_caller_identity" "current" {}
