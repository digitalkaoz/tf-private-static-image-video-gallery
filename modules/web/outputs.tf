output "bucket_domain" {
  value = "${aws_s3_bucket.web.bucket_domain_name}"
}

output "bucket_id" {
  value = "${aws_s3_bucket.web.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.web.arn}"
}
