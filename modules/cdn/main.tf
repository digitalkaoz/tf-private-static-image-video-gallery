data "aws_acm_certificate" "cert" {
  domain   = "${var.certdomain != "" ? var.certdomain : var.domain}"
  provider = "aws.us"
  statuses = ["ISSUED"]
}
