output "cloudfront_oai" {
  value = "${aws_cloudfront_origin_access_identity.oai.iam_arn}"
}

output "cloudfront_arn" {
  value = "${aws_cloudfront_distribution.web.arn}"
}
