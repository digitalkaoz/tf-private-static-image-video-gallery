resource "aws_elastictranscoder_pipeline" "process_videos" {
  provider      = "aws.${var.transcoder_region}"
  name          = "${replace(var.domain,".","_")}"
  input_bucket  = "${var.source_bucket_name}"
  role          = "${aws_iam_role.process.arn}"
  output_bucket = "${aws_s3_bucket.processed.bucket}"
}
