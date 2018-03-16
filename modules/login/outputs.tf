output "lambda_arn" {
  value = "${aws_lambda_function.login.arn}"
}

output "lambda_invoke_url" {
  value = "${aws_api_gateway_deployment.login.invoke_url}"
}

output "role_arn" {
  value = "${aws_iam_role.login.arn}"
}

output "cognito_pool" {
  value = "${aws_cognito_user_pool.users.arn}"
}
