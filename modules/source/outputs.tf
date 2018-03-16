output "bucket_domain" {
  value = "${aws_s3_bucket.source.bucket_domain_name}"
}

output "source_bucket_arn" {
  value = "${aws_s3_bucket.source.arn}"
}

output "bucket_id" {
  value = "${aws_s3_bucket.source.id}"
}

output "bucket_name" {
  value = "${aws_s3_bucket.source.bucket}"
}
