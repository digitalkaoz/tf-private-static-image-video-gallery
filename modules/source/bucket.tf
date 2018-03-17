data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "AllowRead"

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${local.s3_arn}/*",
      "${local.s3_arn}",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "${var.origin-access-identity-arn}",
        "${var.process_role}",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.domain}.process",
      ]
    }
  }
}

resource "aws_s3_bucket" "source" {
  bucket = "${local.s3_domain}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"

  //  server_side_encryption_configuration {
  //    rule {
  //      apply_server_side_encryption_by_default = {
  //        kms_master_key_id = "${var.kms_key_id}"
  //        sse_algorithm = "aws:kms"
  //      }
  //    }
  //  }

  tags {
    Site = "${var.domain}"
  }
}

resource "aws_s3_bucket_object" "original" {
  bucket = "${aws_s3_bucket.source.id}"
  key = "original/"
  source = "/dev/null"
  etag = "${md5("")}"
}

resource "aws_s3_bucket_notification" "source_media_modified" {
  bucket = "${aws_s3_bucket.source.id}"

  # todo cant we iterate over lambda_function somehow?
  lambda_function {
    lambda_function_arn = "${var.resize_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = "${var.resize_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".JPG"
  }

  lambda_function {
    lambda_function_arn = "${var.resize_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".png"
  }

  lambda_function {
    lambda_function_arn = "${var.resize_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".PNG"
  }

  lambda_function {
    lambda_function_arn = "${var.resize_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".jpeg"
  }

  lambda_function {
    lambda_function_arn = "${var.resize_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".JPEG"
  }

  lambda_function {
    lambda_function_arn = "${var.encode_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".mov"
  }

  lambda_function {
    lambda_function_arn = "${var.encode_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".MOV"
  }

  lambda_function {
    lambda_function_arn = "${var.encode_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".mp4"
  }

  lambda_function {
    lambda_function_arn = "${var.encode_lambda_arn}"
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_suffix       = ".MP4"
  }
}
