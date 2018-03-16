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
        "${var.process_arn}",
      ]
    }
  }

  statement {
    sid = "AllowWrite"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
    ]

    resources = [
      "${local.s3_arn}/*",
      "${local.s3_arn}",
    ]

    principals {
      identifiers = ["${var.process_arn}"]
      type        = "AWS"
    }
  }
}

resource "aws_s3_bucket" "web" {
  bucket = "${local.s3_domain}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"

  tags {
    Site = "${var.domain}"
  }
}

//resource "aws_s3_bucket_policy" "web" {
//  bucket = "${aws_s3_bucket.web.id}"
//  policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Sid": "AllowCloudFrontRead",
//      "Effect": "Allow",
//      "Principal": {
//          "AWS": "${var.origin-access-identity-arn}"
//      },
//      "Action": "s3:GetObject",
//      "Resource": "${aws_s3_bucket.web.arn}/*"
//    },
//    {
//      "Sid": "AllowProcessWrite",
//      "Effect": "Allow",
//      "Principal": {
//          "AWS": "${var.process_arn}"
//      },
//      "Action": [
//        "s3:ListBucket",
//        "s3:PutObject",
//        "s3:DeleteObject"
//      ],
//      "Resource": [
//        "${aws_s3_bucket.web.arn}/*",
//        "${aws_s3_bucket.web.arn}"
//      ]
//    }
//  ]
//}
//POLICY
////  policy = "${data.aws_iam_policy_document.cloudfront_read.json}"
//}

