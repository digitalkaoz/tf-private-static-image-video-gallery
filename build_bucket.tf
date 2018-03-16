resource "aws_s3_bucket" "build" {
  bucket = "build.${var.domain}"

  tags {
    Site = "${var.domain}"
  }
}
