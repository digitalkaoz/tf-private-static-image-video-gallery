resource "null_resource" "resize_build" {
  triggers {
    main    = "${sha256(file("${path.module}/resize/index.js"))}"
    package = "${sha256(file("${path.module}/resize/package.json"))}"
    path    = "${path.module}/resize"
  }

  provisioner "local-exec" {
    command = <<EOF
        export VOLUME="-v ${path.module}/resize:${path.module}/resize"

        docker run \
          $VOLUME \
          --workdir="${path.module}/resize" \
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

data "archive_file" "resize_code" {
  source_dir  = "${null_resource.resize_build.triggers.path}"
  output_path = "${path.module}/lambda-resize.zip"
  type        = "zip"
}

resource "aws_s3_bucket_object" "resize_code" {
  bucket = "${var.build_bucket_id}"
  key    = "lambda-resize.zip"
  source = "${data.archive_file.resize_code.output_path}"
  etag   = "${data.archive_file.resize_code.output_md5}"
}

resource "aws_lambda_function" "resize" {
  function_name    = "resize_${replace(var.domain, ".", "_")}"
  handler          = "index.handler"
  role             = "${aws_iam_role.process.arn}"
  runtime          = "nodejs6.10"
  s3_bucket        = "${var.build_bucket_id}"
  s3_key           = "${aws_s3_bucket_object.resize_code.key}"
  source_code_hash = "${aws_s3_bucket_object.resize_code.etag}"
  timeout          = 20
  memory_size      = 1024

  environment {
    variables {
      RESIZED_BUCKET = "${aws_s3_bucket.processed.id}"
      KMS_KEY_NAME   = "${var.kms_key_name}"
    }
  }

  tags = {
    Site = "${var.domain}"
  }
}

resource "aws_lambda_permission" "resize" {
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.resize.id}"
  principal      = "s3.amazonaws.com"
  source_account = "${data.aws_caller_identity.current.account_id}"
  source_arn     = "${var.source_bucket_arn}"
  statement_id   = "AllowInvokeResizeLambda"
}
