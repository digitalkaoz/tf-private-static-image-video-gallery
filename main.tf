data "aws_caller_identity" "current" {}

module "cdn" {
  source           = "./modules/cdn"
  domain           = "${var.domain}"
  certdomain       = "${var.certdomain}"
  web_origin       = "${module.web.bucket_domain}"
  login_origin     = "${module.login.lambda_invoke_url}"
  source_origin    = "${module.source.bucket_domain}"
  processed_origin = "${module.process.bucket_domain}"
}

module "login" {
  source                           = "./modules/login"
  domain                           = "${var.domain}"
  kms_key_arn                      = "${aws_kms_alias.kms_key.arn}"
  cloudfront_key_pair              = "${var.cloudfront_key_pair}"
  encrypted_cloudfront_private_key = "${chomp(module.encrypted_cf_key.stdout)}"
  region                           = "${var.region}"
  build_bucket_id                  = "${aws_s3_bucket.build.id}"
}

module "source" {
  source                     = "./modules/source"
  domain                     = "${var.domain}"
  origin-access-identity-arn = "${module.cdn.cloudfront_oai}"
  kms_key_id                 = "${aws_kms_alias.kms_key.id}"
  resize_lambda_arn          = "${module.process.resize_arn}"
  encode_lambda_arn          = "${module.process.encode_arn}"
  process_role               = "${module.process.process_role}"
}

module "process" {
  source                           = "./modules/process"
  domain                           = "${var.domain}"
  origin-access-identity-arn       = "${module.cdn.cloudfront_oai}"
  kms_key_arn                      = "${aws_kms_alias.kms_key.arn}"
  kms_key_name                     = "${aws_kms_alias.kms_key.name}"
  kms_key_id                       = "${aws_kms_alias.kms_key.id}"
  cloudfront_key_pair              = "${var.cloudfront_key_pair}"
  encrypted_cloudfront_private_key = "${var.encrypted_cloudfront_private_key}"
  source_bucket_arn                = "${module.source.source_bucket_arn}"
  build_bucket_id                  = "${aws_s3_bucket.build.id}"
  source_bucket_name               = "${module.source.bucket_name}"
}

module "web" {
  source                     = "./modules/web"
  domain                     = "${var.domain}"
  origin-access-identity-arn = "${module.cdn.cloudfront_oai}"
  process_arn                = "${module.process.process_role}"
}

module "build" {
  source               = "./modules/build"
  domain               = "${var.domain}"
  kms_key_arn          = "${aws_kms_alias.kms_key.arn}"
  web_bucket_id        = "${module.web.bucket_id}"
  source_bucket_id     = "${module.source.bucket_id}"
  processed_bucket_arn = "${module.process.bucket_arn}"
  source_bucket_arn    = "${module.source.source_bucket_arn}" # todo remove source_ prefix
  web_bucket_arn       = "${module.web.bucket_arn}"
  region               = "${var.region}"
  cloudfront_arn       = "${module.cdn.cloudfront_arn}"
  build_bucket_id      = "${aws_s3_bucket.build.id}"
  website_config       = "${var.website_config}"
}
