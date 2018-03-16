resource "aws_kms_key" "kms_key" {
  policy = "${data.aws_iam_policy_document.kms_key.json}"

  tags = {
    Site = "${var.domain}"
  }
}

resource "aws_kms_alias" "kms_key" {
  target_key_id = "${aws_kms_key.kms_key.id}"
  name          = "alias/${replace(var.domain, ".", "-")}"
}

data "aws_iam_policy_document" "kms_key" {
  statement {
    sid       = "admin"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]

      type = "AWS"
    }
  }

  statement {
    sid       = "usage"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:Recrypt",
      "kms:DescribeKey",
      "kms:GenerateRandom",
      "kms:GenerateDataKey",
      "kms:ReEncryptTo",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
    ]

    principals {
      identifiers = [
        "${module.login.role_arn}",
        "${module.process.process_role}",
        "${module.build.role_arn}",
      ]

      type = "AWS"
    }
  }
}
