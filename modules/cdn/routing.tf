#for TLD create zone and records
resource "aws_route53_zone" "web" {
  count = "${var.certdomain == "" ? 1 : 0}"
  name  = "${var.domain}"

  tags {
    Site = "${var.domain}"
  }
}

resource "aws_route53_record" "www" {
  count   = "${var.certdomain == "" ? 1 : 0}"
  name    = "${var.domain}"
  type    = "A"
  zone_id = "${aws_route53_zone.web.id}"

  alias {
    evaluate_target_health = false
    name                   = "${aws_cloudfront_distribution.web.domain_name}"
    zone_id                = "Z2FDTNDATAQYW2"                                 #cloudfront default
  }
}

resource "aws_route53_record" "mx" {
  count   = "${var.certdomain == "" ? 1 : 0}"
  name    = "${var.domain}"
  type    = "MX"
  ttl     = 3600
  zone_id = "${aws_route53_zone.web.id}"
  records = "${var.mx_hosts}"
}

# in case its a subdomain, simply add a record set
data "aws_route53_zone" "web" {
  count = "${var.certdomain != "" ? 1 : 0}"
  name  = "${var.certdomain}."
}

resource "aws_route53_record" "subdomain" {
  count   = "${var.certdomain != "" ? 1 : 0}"
  name    = "${var.domain}"
  type    = "CNAME"
  zone_id = "${data.aws_route53_zone.web.0.zone_id}"
  ttl     = 3600

  records = [
    "${aws_cloudfront_distribution.web.domain_name}",
  ]
}
