### Cognito Pool 
resource "aws_cognito_user_pool" "wallet-user-pool" {
    name = "Web3AuthWalletLogin"

    lambda_config {
        //Create auth challenge
        //create_auth_challenge           = module.lambda-function-auth-create.lambda_function_arn
        //Define auth challenge
        //define_auth_challenge           = module.lambda-function-auth-define.lambda_function_arn
        //Post authentication
        //post_authentication             = module.lambda-function-auth-post.lambda_function_arn
        //Pre sign-up
        //pre_sign_up                     = module.lambda-function-auth-presignup.lambda_function_arn
        //Verify auth challenge response
        //verify_auth_challenge_response  = module.lambda-function-auth-verify.lambda_function_arn
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