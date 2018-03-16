resource "null_resource" "encode_build" {
  triggers {
    main    = "${sha256(file("${path.module}/encode/index.js"))}"
    package = "${sha256(file("${path.module}/encode/package.json"))}"
  }

  provisioner "local-exec" {
    command = <<EOF
        export VOLUME="-v ${path.module}/encode:${path.module}/encode"

        docker run \
          $VOLUME \
          --workdir="${path.module}/encode" \
          --entrypoint bash \
          lambci/lambda:build-nodejs6.10 \
          -c "\
            rm -rf node_modules \
            && npm install --production \
            && npm rebuild --force
          "
        EOF
  }
}

data "archive_file" "encode_code" {
  depends_on  = ["null_resource.encode_build"]
  source_dir  = "${path.module}/encode"
  output_path = "${path.module}/lambda-encode.zip"
  type        = "zip"
}

resource "aws_s3_bucket_object" "encode_code" {
  depends_on = ["data.archive_file.encode_code"]
  bucket     = "${var.build_bucket_id}"
  key        = "lambda-encode.zip"
  source     = "${path.module}/lambda-encode.zip"
  etag       = "${md5(file("${path.module}/lambda-encode.zip"))}"
}

resource "aws_lambda_function" "encode" {
  function_name    = "encode_${replace(var.domain, ".", "_")}"
  handler          = "index.handler"
  role             = "${aws_iam_role.process.arn}"
  runtime          = "nodejs6.10"
  s3_bucket        = "${var.build_bucket_id}"
  s3_key           = "${aws_s3_bucket_object.encode_code.key}"
  source_code_hash = "${aws_s3_bucket_object.encode_code.etag}"
  timeout          = 10
  memory_size      = 256

  environment {
    variables {
      REGION         = "${var.transcoder_region}"
      PIPELINE_ID    = "${aws_elastictranscoder_pipeline.process_videos.id}"
      RESIZED_BUCKET = "${aws_s3_bucket.processed.id}"
      PRESET_ID      = "1351620000001-000010"
    }
  }

  tags = {
    Site = "${var.domain}"
  }
}

resource "aws_lambda_permission" "encode" {
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.encode.id}"
  principal      = "s3.amazonaws.com"
  source_account = "${data.aws_caller_identity.current.account_id}"
  source_arn     = "${var.source_bucket_arn}"
  statement_id   = "AllowInvokeResizeLambda"
}
