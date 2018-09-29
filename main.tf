resource "aws_api_gateway_rest_api" "api" {
  name = "${var.name}"
  description = "${var.description}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part = "{proxy+}"
}
resource "aws_api_gateway_method" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "ANY"
  authorization = "${var.cognito_user_pool_auth == 1 ? "COGNITO_USER_POOLS" : "NONE"}"
  authorizer_id = "${var.cognito_user_pool_auth == 1 ? aws_api_gateway_authorizer.main.id : ""}"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.api.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  http_method = "ANY"
  authorization = "${var.cognito_user_pool_auth == 1 ? "COGNITO_USER_POOLS" : "NONE"}"
  authorizer_id = "${var.cognito_user_pool_auth == 1 ? aws_api_gateway_authorizer.main.id : ""}"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.api.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name = "${var.stage_name}"
  description = "${var.stage_description}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.api.arn}"
  principal = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.api.execution_arn}/*/*"
}

resource "aws_api_gateway_authorizer" "main" {
  count = "${var.cognito_user_pool_auth}"
  name = "cognito"
  type = "COGNITO_USER_POOLS"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  provider_arns = [
    "${var.cognito_user_pool_arn}"
  ]
  identity_source = "method.request.header.Authorization"
  authorizer_uri = ""
}

resource "aws_lambda_function" "api" {
  function_name = "${var.name}"
  s3_bucket = "${var.lambda_artifact_bucket}"
  s3_key = "${var.lambda_artifact_key}"
  handler = "${var.lambda_handler}"
  runtime = "${var.lambda_runtime}"
  timeout = "${var.lambda_timeout}"
  role = "${aws_iam_role.api.arn}"
  environment = "${var.lambda_environment}"
}

resource "aws_iam_role" "api" {
  name = "${var.name}-lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "api" {
  name = "${var.name}-lambda-logs"
  role = "${aws_iam_role.api.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}
