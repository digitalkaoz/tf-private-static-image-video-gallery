data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "AllowRead"

    actions = [
      "s3:Get*",
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
        "${aws_iam_role.process.arn}",
      ]
    }
  }

  statement {
    sid = "AllowWrite"

    actions = [
      "s3:Put*",
      "s3:*Delete*",
    ]

    resources = [
      "${local.s3_arn}/*",
      "${local.s3_arn}",
    ]

    principals {
      identifiers = [
        "${aws_iam_role.process.arn}",
      ]

      type = "AWS"
    }
  }
}

resource "aws_s3_bucket" "processed" {
  bucket = "${local.s3_domain}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"

  //  server_side_encryption_configuration {
  //    rule {
  //      apply_server_side_encryption_by_default = {
  //        kms_master_key_id = "${var.kms_key_id}"
  //        sse_algorithm     = "aws:kms"
  //      }
  //    }
  //  }

  tags {
    Site = "${var.domain}"
  }
}
