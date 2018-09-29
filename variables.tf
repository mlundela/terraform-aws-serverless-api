variable "name" {
  description = "Name"
}
variable "description" {
  description = "Description"
  default = "REST API"
}
variable "stage_name" {
  description = "API Gateway stage"
  default = "api"
}
variable "stage_description" {
  description = "API Gateway stage description"
  default = ""
}
variable "cognito_user_pool_auth" {
  description = "Enable authentication with Cognito"
  default = false
}
variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN. Required if cognito_user_pool_auth = true"
  default = ""
}
variable "lambda_artifact_bucket" {
  description = "Lambda zip file S3 bucket"
}
variable "lambda_artifact_key" {
  description = "Lambda zip file S3 key"
}
variable "lambda_timeout" {
  description = "Lambda function timeout"
  default = "10"
}
variable "lambda_runtime" {
  description = "Lambda function runtime"
  default = "nodejs8.10"
}
variable "lambda_handler" {
  description = "Lambda function handler"
  default = "index.handle"
}

variable "lambda_environment" {
  description = "Lambda function environment"
  type = "list"
  default = []
}
