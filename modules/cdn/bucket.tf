resource "aws_s3_bucket" "log" {
  bucket = "log.${var.domain}"
  acl    = "log-delivery-write"

  tags {
    Site = "${var.domain}"
  }
}
