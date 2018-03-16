data "aws_iam_policy_document" "build" {
  statement {
    sid       = "UseKms"
    effect    = "Allow"
    actions   = ["kms:*"]              #todo more restrictive policy
    resources = ["${var.kms_key_arn}"]
  }

  statement {
    sid    = "ModifyBucketObjects"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${var.web_bucket_arn}",
      "${var.web_bucket_arn}/*",
    ]
  }

  statement {
    sid    = "AllowCloudfrontInvalidation"
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ListCloudfrontDistributions"
    effect = "Allow"

    actions = [
      "cloudfront:ListDistributions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ReadBucketObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${var.processed_bucket_arn}/*",
      "${var.processed_bucket_arn}",
      "${var.source_bucket_arn}/*",
      "${var.source_bucket_arn}",
      "${var.web_bucket_arn}",
      "${var.web_bucket_arn}/*",
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

resource "aws_iam_role" "build" {
  name               = "${var.domain}.build"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

resource "aws_iam_role_policy" "build" {
  name   = "${var.domain}.build"
  role   = "${aws_iam_role.build.id}"
  policy = "${data.aws_iam_policy_document.build.json}"
}

resource "aws_iam_role_policy_attachment" "build" {
  role       = "${aws_iam_role.build.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
