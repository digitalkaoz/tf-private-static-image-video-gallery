resource "aws_api_gateway_rest_api" "login" {
  name        = "${var.domain}"
  description = "Apis for ${var.domain}"
}

resource "aws_api_gateway_resource" "login" {
  rest_api_id = "${aws_api_gateway_rest_api.login.id}"
  parent_id   = "${aws_api_gateway_rest_api.login.root_resource_id}"
  path_part   = "login"
}

resource "aws_api_gateway_method" "login" {
  rest_api_id   = "${aws_api_gateway_rest_api.login.id}"
  resource_id   = "${aws_api_gateway_resource.login.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "login" {
  rest_api_id             = "${aws_api_gateway_rest_api.login.id}"
  resource_id             = "${aws_api_gateway_resource.login.id}"
  http_method             = "${aws_api_gateway_method.login.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.login.arn}/invocations"
}

resource "aws_api_gateway_deployment" "login" {
  rest_api_id = "${aws_api_gateway_rest_api.login.id}"
  stage_name  = "Prod"
}
