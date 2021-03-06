resource "null_resource" "build_build" {
  triggers {
    main    = "${sha256(file("${path.module}/function/index.js"))}"
    package = "${sha256(file("${path.module}/function/package.json"))}"
    config  = "${sha256(file("${path.module}/function/gatsby-config.js"))}"
    layout  = "${sha256(file("${path.module}/function/src/layouts/index.js"))}"
    html    = "${sha256(file("${path.module}/function/src/html.js"))}"
    dirname = "function"
  }

  provisioner "local-exec" {
    command = <<EOF
        export VOLUME="-v ${path.module}/function:${path.module}/function"

        docker run \
          $VOLUME \
          --workdir="${path.module}/function" \
          --entrypoint bash \
          lambci/lambda:build-nodejs8.10 \
          -c "\
            rm -rf node_modules \
            && npm i -g npm@latest \
            && NODE_ENV=production npm ci --production \
            && cp patch/pages-writer.js node_modules/gatsby/dist/internal-plugins/query-runner/pages-writer.js \
            && rm -rf public \
            && rm -rf .cache
          "
        EOF
  }
}

data "archive_file" "build_code" {
  depends_on  = ["null_resource.build_build"]
  source_dir  = "${path.module}/${null_resource.build_build.triggers.dirname}"
  output_path = "${path.module}/lambda-build.zip"
  type        = "zip"
}

resource "aws_s3_bucket_object" "build_code" {
  depends_on = ["null_resource.build_build"]
  bucket     = "${var.build_bucket_id}"
  key        = "lambda-build.zip"
  source     = "${data.archive_file.build_code.output_path}"
  etag       = "${data.archive_file.build_code.output_md5}"
}

resource "aws_lambda_function" "build" {
  function_name    = "build_${replace(var.domain, ".", "_")}"
  handler          = "index.handler"
  role             = "${aws_iam_role.build.arn}"
  runtime          = "nodejs8.10"
  s3_bucket        = "${var.build_bucket_id}"
  s3_key           = "${aws_s3_bucket_object.build_code.key}"
  source_code_hash = "${data.archive_file.build_code.output_base64sha256}"
  timeout          = 120
  memory_size      = 2048

  environment {
    variables {
      ORIGINAL_BUCKET = "${var.source_bucket_id}"
      SITE_BUCKET     = "${var.web_bucket_id}"
      WEBSITE         = "${var.domain}"
      CONFIG          = "${jsonencode(var.website_config)}"
      NODE_ENV        = "production"
    }
  }
}

#allow cloudwatch to invoke our function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.build.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.generate_website_event.arn}"
}

# invoke the lambda when function changes
resource "null_resource" "invoke_build" {
  depends_on = ["null_resource.build_build"]

  triggers {
    state = "${data.archive_file.build_code.output_md5}"
  }

  provisioner "local-exec" {
    command = "aws lambda --region ${var.region} invoke --function-name ${aws_lambda_function.build.arn} /dev/null"
  }
}
