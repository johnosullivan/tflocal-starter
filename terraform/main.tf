locals {
  environment = terraform.workspace
}

### Example Lambda Functions
module "lambda-function-helloworld" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "lambda-function-helloworld-${local.environment}"

  description = "helloworld example lambda function"
  handler     = "helloworld"
  runtime     = "go1.x"

  source_path = "../src/bin/helloworld/helloworld"

  architectures = ["x86_64"]

  tags = {
    Name        = "lambda-function-helloworld-${local.environment}"
    Environment = local.environment
  }

  attach_policies    = false
  environment_variables = {}

  timeout     = 60
  memory_size = 256
}

// Lambda Presignup 
module "lambda-function-auth-presignup" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "lambda-function-auth-presignup-${local.environment}"
  description = "auth pre-signup lambda function"

  handler     = "index.handler"
  source_path = "../src/authentication/presignup"

  runtime     = "nodejs18.x"
  architectures = ["x86_64"]

  tags = {
    Name        = "lambda-function-auth-presignup-${local.environment}"
    Environment = local.environment
  }

  attach_policies    = false
  environment_variables = {}

  timeout     = 60
  memory_size = 256
}

// Lambda Post Auth
module "lambda-function-auth-post" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "lambda-function-auth-post-${local.environment}"
  description = "auth post lambda function"

  handler     = "index.handler"
  source_path = "../src/authentication/postauth"

  runtime     = "nodejs18.x"
  architectures = ["x86_64"]

  tags = {
    Name        = "lambda-function-auth-post-${local.environment}"
    Environment = local.environment
  }

  attach_policies    = false
  environment_variables = {}

  timeout     = 60
  memory_size = 256
}


// Lambda Define 
module "lambda-function-auth-define" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "lambda-function-auth-define-${local.environment}"
  description = "auth define lambda function"

  handler     = "index.handler"
  source_path = "../src/authentication/define"

  runtime     = "nodejs18.x"
  architectures = ["x86_64"]

  tags = {
    Name        = "lambda-function-auth-define-${local.environment}"
    Environment = local.environment
  }

  attach_policies    = false
  environment_variables = {}

  timeout     = 60
  memory_size = 256
}

// Lambda Create 
module "lambda-function-auth-create" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "lambda-function-auth-create-${local.environment}"
  description = "auth create lambda function"

  handler     = "index.handler"
  source_path = "../src/authentication/create"

  runtime     = "nodejs18.x"
  architectures = ["x86_64"]

  tags = {
    Name        = "lambda-function-auth-create-${local.environment}"
    Environment = local.environment
  }

  attach_policies    = false
  environment_variables = {}

  timeout     = 60
  memory_size = 256
}

// Lambda Verify 
module "lambda-function-auth-verify" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"

  function_name = "lambda-function-auth-verify-${local.environment}"
  description = "auth verify lambda function"

  handler     = "index.handler"
  source_path = "../src/authentication/verify"

  runtime     = "nodejs18.x"
  architectures = ["x86_64"]

  tags = {
    Name        = "lambda-function-auth-verify-${local.environment}"
    Environment = local.environment
  }

  attach_policies    = false
  environment_variables = {}

  timeout     = 60
  memory_size = 256
}

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

### Cognito Pool 
resource "aws_cognito_user_pool" "wallet-user-pool" {
    name = "Web3AuthWalletLogin"

    lambda_config {
        //Create auth challenge
        create_auth_challenge           = module.lambda-function-auth-create.lambda_function_arn
        //Define auth challenge
        define_auth_challenge           = module.lambda-function-auth-define.lambda_function_arn
        //Post authentication
        post_authentication             = module.lambda-function-auth-post.lambda_function_arn
        //Pre sign-up
        pre_sign_up                     = module.lambda-function-auth-presignup.lambda_function_arn
        //Verify auth challenge response
        verify_auth_challenge_response  = module.lambda-function-auth-verify.lambda_function_arn
    }
}

resource "aws_cognito_user_pool_client" "wallet-user-pool-client" {
  name = "WebAuthWalletLogin"

  callback_urls       = ["https://example.com"]
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  access_token_validity  = 24
  id_token_validity      = 24
  refresh_token_validity = 1

  token_validity_units {
    access_token  = "hours"  // access_token - (Optional) Time unit in for the value in access_token_validity, defaults to hours.
    id_token      = "hours"  // id_token - (Optional) Time unit in for the value in id_token_validity, defaults to hours.
    refresh_token = "days"   // refresh_token - (Optional) Time unit in for the value in refresh_token_validity, defaults to days.
  }

  user_pool_id = aws_cognito_user_pool.wallet-user-pool.id
}

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

// REST API
resource "aws_api_gateway_rest_api" "helloworld" {
  name = "helloworld-${local.environment}"

  endpoint_configuration {
    types = ["EDGE"]
  }
}

// X-ZTX-Authorization
resource "aws_api_gateway_authorizer" "cog-authorizer" {
  name            = "TF_HELLOWORLD_COGNITO_AUTHORIZER"
  rest_api_id     = aws_api_gateway_rest_api.helloworld.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [
    aws_cognito_user_pool.wallet-user-pool.arn
  ]
  identity_source = "method.request.header.X-Authorization"
}

resource "aws_api_gateway_resource" "helloworld-id" {
  rest_api_id = aws_api_gateway_rest_api.helloworld.id
  parent_id   = aws_api_gateway_rest_api.helloworld.root_resource_id
  path_part   = "{item_id}"
}

resource "aws_api_gateway_method" "helloworld-id-get" {
  rest_api_id   = aws_api_gateway_rest_api.helloworld.id
  resource_id   = aws_api_gateway_resource.helloworld-id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cog-authorizer.id
}

resource "aws_api_gateway_integration" "helloworld-id-get-integration" {
  rest_api_id             = aws_api_gateway_rest_api.helloworld.id
  resource_id             = aws_api_gateway_resource.helloworld-id.id
  http_method             = aws_api_gateway_method.helloworld-id-get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda-function-helloworld.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "apigw-lambda-get" {
  statement_id  = "AllowExecutionFromAPIGatewayHelloWorld"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda-function-helloworld.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.helloworld.execution_arn}/*/${aws_api_gateway_method.helloworld-id-get.http_method}/*"
}

resource "aws_api_gateway_stage" "helloworld-stage" {
  deployment_id = aws_api_gateway_deployment.helloworld-deployment.id
  rest_api_id   = aws_api_gateway_rest_api.helloworld.id
  stage_name    = "prod"
}

resource "aws_api_gateway_deployment" "helloworld-deployment" {
  rest_api_id = aws_api_gateway_rest_api.helloworld.id

  triggers = {
    redeployment = sha1(jsonencode([
      module.lambda-function-helloworld.lambda_function_invoke_arn,
      aws_api_gateway_resource.helloworld-id.id,
      aws_lambda_permission.apigw-lambda-get.id,
      aws_api_gateway_integration.helloworld-id-get-integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}