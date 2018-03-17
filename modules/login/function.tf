resource "null_resource" "login_build" {
  triggers {
    main    = "${sha256(file("${path.module}/function/index.js"))}"
    package = "${sha256(file("${path.module}/function/package.json"))}"
  }

  provisioner "local-exec" {
    command = <<EOF
        export VOLUME="-v ${path.module}/function:${path.module}/function"

        docker run \
          $VOLUME \
          --workdir="${path.module}/function" \
          --entrypoint bash \
          lambci/lambda:build-nodejs6.10 \
          -c "\
            rm -rf node_modules \
            && npm install --production \
          "
        EOF
  }
}

data "archive_file" "login_code" {
  depends_on  = ["null_resource.login_build"]
  source_dir  = "${path.module}/function"
  output_path = "${path.module}/lambda-login.zip"
  type        = "zip"
}

resource "aws_s3_bucket_object" "login_code" {
  depends_on  = ["null_resource.login_build"]
  bucket = "${var.build_bucket_id}"
  key    = "lambda-login.zip"
  source = "${data.archive_file.login_code.output_path}"
  etag   = "${data.archive_file.login_code.output_md5}"
}

resource "aws_lambda_function" "login" {
  function_name    = "login_${replace(var.domain, ".", "_")}"
  handler          = "index.handler"
  role             = "${aws_iam_role.login.arn}"
  runtime          = "nodejs6.10"
  s3_bucket        = "${var.build_bucket_id}"
  s3_key           = "${aws_s3_bucket_object.login_code.key}"
  source_code_hash = "${aws_s3_bucket_object.login_code.etag}"

  environment {
    variables {
      WEBSITE_DOMAIN                   = "${var.domain}"
      SESSION_DURATION                 = 86400
      CLOUDFRONT_KEYPAIR_ID            = "${var.cloudfront_key_pair}"
      ENCRYPTED_CLOUDFRONT_PRIVATE_KEY = "${var.encrypted_cloudfront_private_key}"
      COGNITO_POOL                     = "${aws_cognito_user_pool.users.id}"
      COGNITO_APP                      = "${aws_cognito_user_pool_client.website.id}"
    }
  }

  tags = {
    Site = "${var.domain}"
  }
}

data "aws_iam_policy_document" "login" {
  statement {
    sid       = "AllowKms"
    actions   = ["kms:*Encrypt*", "kms:*Decrypt*"]
    resources = ["${var.kms_key_arn}"]
  }

  statement {
    sid     = "AllowCognito"
    actions = ["cognito-idp:AdminInitiateAuth"]

    resources = [
      "${aws_cognito_user_pool.users.arn}",
    ]
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "AllowLambdaServiceToAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "login" {
  name               = "${var.domain}.login"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

resource "aws_iam_role_policy" "login" {
  name   = "${var.domain}.login"
  role   = "${aws_iam_role.login.id}"
  policy = "${data.aws_iam_policy_document.login.json}"
}

resource "aws_iam_role_policy_attachment" "login" {
  role       = "${aws_iam_role.login.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "apigw_login" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.login.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${replace(aws_api_gateway_deployment.login.execution_arn, aws_api_gateway_deployment.login.stage_name, "*")}/POST/login"
}
