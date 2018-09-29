# terraform-aws-serverless-api
Terraform module for API Gateway with AWS Lambda backend

Inspired by the following article: 
https://www.terraform.io/docs/providers/aws/guides/serverless-with-aws-lambda-and-api-gateway.html

## Usage

    module "hello_api" {
      source = "mlundela/serverless-api/aws"
      version = "1.0.1"
      
      name = "hello"
      lambda_artifact_bucket = "my-artifacts-bucket"
      lambda_artifact_key = "lambda/hello-04b2add.zip"
      
      // With authentication (Optional)
      cognito_user_pool_auth = true
      cognito_user_pool_arn = "${module.auth.cognito_user_pool_arn}"
    }
