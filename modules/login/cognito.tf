resource "aws_cognito_user_pool" "users" {
  name = "${var.domain}"

  admin_create_user_config {
    allow_admin_create_user_only = true
    unused_account_validity_days = 30
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  tags = {
    Site = "${var.domain}"
  }
}

resource "aws_cognito_user_pool_client" "website" {
  name                = "${var.domain}"
  user_pool_id        = "${aws_cognito_user_pool.users.id}"
  generate_secret     = false
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
}
