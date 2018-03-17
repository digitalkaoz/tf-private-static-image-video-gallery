resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.domain}"
}

resource "aws_cloudfront_distribution" "web" {
  aliases             = ["${var.domain}"]
  price_class         = "PriceClass_100"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {
    domain_name = "${replace(replace(var.login_origin, "https://", ""), "/Prod", "")}"
    origin_id   = "login.${var.domain}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"] #todo disable unneeded onces
    }
  }

  origin {
    domain_name = "${var.source_origin}"
    origin_id   = "source.${var.domain}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path}"
    }
  }

  origin {
    domain_name = "${var.web_origin}"
    origin_id   = "${var.domain}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path}"
    }
  }

  origin {
    domain_name = "${var.processed_origin}"
    origin_id   = "processed.${var.domain}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path}"
    }
  }

  cache_behavior {
    target_origin_id       = "processed.${var.domain}"
    path_pattern           = "original/*/*.mp4"
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    default_ttl            = 86400
    max_ttl                = 86400
    min_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    trusted_signers        = ["self"]

    "forwarded_values" {
      cookies {
        forward = "all"
      }

      query_string = false
    }
  }

  cache_behavior {
    target_origin_id       = "processed.${var.domain}"
    path_pattern           = "original/*/*.png"
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    default_ttl            = 86400
    max_ttl                = 86400
    min_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    trusted_signers        = ["self"]

    "forwarded_values" {
      cookies {
        forward = "all"
      }

      query_string = false
    }
  }

  cache_behavior {
    target_origin_id       = "processed.${var.domain}"
    path_pattern           = "pics/resized/*"
    allowed_methods        = ["HEAD", "GET", "OPTIONS"]
    cached_methods         = ["HEAD", "GET", "OPTIONS"]
    default_ttl            = 86400
    max_ttl                = 86400
    min_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    trusted_signers        = ["self"]

    "forwarded_values" {
      cookies {
        forward = "all"
      }

      query_string = false
    }
  }

  cache_behavior {
    target_origin_id       = "login.${var.domain}"
    path_pattern           = "Prod/*"
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["HEAD", "GET"]
    default_ttl            = 86400
    max_ttl                = 86400
    min_ttl                = 86400
    viewer_protocol_policy = "https-only"

    "forwarded_values" {
      "cookies" {
        forward = "all"
      }

      headers      = ["Accept", "Authorization", "Content-Type", "Referer"]
      query_string = false
    }
  }

  default_cache_behavior {
    target_origin_id       = "${var.domain}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    default_ttl            = 86400
    trusted_signers        = ["self"]
    max_ttl                = 86400
    min_ttl                = 86400
    compress               = true

    "forwarded_values" {
      cookies {
        forward = "all"
      }

      query_string = false
    }
  }

  custom_error_response {
    error_code         = 403
    response_page_path = "/error.html"
    response_code      = 403
  }

  custom_error_response {
    error_code         = 404
    response_page_path = "/index.html"
    response_code      = 404
  }

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.log.bucket_domain_name}"
    prefix          = "cf"
  }

  "restrictions" {
    "geo_restriction" {
      restriction_type = "none"
    }
  }

  "viewer_certificate" {
    acm_certificate_arn = "${data.aws_acm_certificate.cert.arn}"
    ssl_support_method  = "sni-only"
  }

  tags {
    Site = "${var.domain}"
  }
}
