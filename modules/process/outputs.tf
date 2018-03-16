output "bucket_domain" {
  value = "${aws_s3_bucket.processed.bucket_domain_name}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.processed.arn}"
}

output "resize_arn" {
  value = "${aws_lambda_function.resize.arn}"
}

output "encode_arn" {
  value = "${aws_lambda_function.encode.arn}"
}

output "process_role" {
  value = "${aws_iam_role.process.arn}"
}
