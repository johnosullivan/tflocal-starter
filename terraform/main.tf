locals {
  environment = terraform.workspace
}
### Example Lambda Functions

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