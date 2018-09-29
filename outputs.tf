output "rest_api_id" {
  value = "${aws_api_gateway_rest_api.api.id}"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.api.invoke_url}"
}

output "lambda_role" {
  value = "${aws_iam_role.api.id}"
}
