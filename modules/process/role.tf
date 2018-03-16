data "aws_iam_policy_document" "process" {
  statement {
    sid    = "UseKms"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateRandom",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncryptTo",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:DescribeKey",
      "kms:ReEncryptFrom",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ModifyBucketObjects"
    effect = "Allow"

    actions = [
      "s3:Put*",
      "s3:DeleteObject",
      "s3:*Delete*",
    ]

    resources = [
      "${aws_s3_bucket.processed.arn}",
      "${aws_s3_bucket.processed.arn}/*",
    ]
  }

  statement {
    sid    = "ReadBucketObjects"
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:ListBucket",
    ]

    resources = [
      "${var.source_bucket_arn}/*",
      "${var.source_bucket_arn}",
    ]
  }

  statement {
    sid    = "createTranscoderJobs"
    effect = "Allow"

    actions = [
      "elastictranscoder:ReadPipeline",
      "elastictranscoder:ReadPreset",
      "elastictranscoder:ReadJob",
      "elastictranscoder:CreateJob",
    ]

    resources = [
      "arn:aws:elastictranscoder:${var.transcoder_region}:${data.aws_caller_identity.current.account_id}:job/*",
      "arn:aws:elastictranscoder:${var.transcoder_region}:${data.aws_caller_identity.current.account_id}:preset/*",
      "${aws_elastictranscoder_pipeline.process_videos.arn}",
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

  "statement" {
    sid     = "AllowTranscoderToAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["elastictranscoder.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "process" {
  name               = "${var.domain}.process"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

resource "aws_iam_role_policy" "process" {
  name   = "${var.domain}.process"
  role   = "${aws_iam_role.process.id}"
  policy = "${data.aws_iam_policy_document.process.json}"
}

resource "aws_iam_role_policy_attachment" "process" {
  role       = "${aws_iam_role.process.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
