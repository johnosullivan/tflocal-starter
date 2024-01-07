#!/bin/bash

# Retrieve USER_POOL_WALLET_ID
export USER_POOL_WALLET_ID=$(awslocal cognito-idp list-user-pools --max-results 10 --output json | jq -c '.UserPools[] | select( .Name | contains("Web3AuthWalletLogin"))' | jq --raw-output -c '.Id')
echo "Wallet User Pool: $USER_POOL_WALLET_ID"
# Retrieve USER_POOL_CLIENT_ID
export USER_POOL_CLIENT_ID=$(awslocal cognito-idp list-user-pool-clients --user-pool-id $USER_POOL_WALLET_ID --output json | jq -c '.UserPoolClients[] | select( .UserPoolId | contains(env.USER_POOL_WALLET_ID))' | jq --raw-output -c '.ClientId')
echo "Client ID: $USER_POOL_CLIENT_ID"
export WALLET_ADDRESS_ONE=0x073E61aa37A06d8121920d6cD743D97dd5Bb71a2
export USERNAME_ONE=wallet_$WALLET_ADDRESS_ONE
# Create Users For e2e
USER=$(awslocal cognito-idp admin-create-user --username $USERNAME_ONE --user-pool-id $USER_POOL_WALLET_ID)
# Force Reset Password => Confirmed State
awslocal cognito-idp admin-set-user-password --user-pool-id $USER_POOL_WALLET_ID \
    --username $USERNAME_ONE \
    --password PaSsW0rD! --permanent
# List Users
USERS=$(awslocal cognito-idp list-users --user-pool-id $USER_POOL_WALLET_ID --output json | jq -c '.Users')
echo $USERS | jq

APIS=$(awslocal apigateway get-rest-apis --query 'items' --output json)

echo $APIS | jq
# https://<api-id>.execute-api.localhost.localstack.cloud:4566/<stage-name>/

HELLOWORLD_API_ID=$(echo $APIS | jq --raw-output -c '.[] | select(.name | contains("helloworld-e2e")) | .id')
HELLOWORLD_API_STAGE="prod"

HELLOWORLD_URL=http://$HELLOWORLD_API_ID.execute-api.localhost.localstack.cloud:4566/$HELLOWORLD_API_STAGE
echo "HELLOWORLD_API_URL: $HELLOWORLD_URL"

USER_AUTH=$(awslocal cognito-idp initiate-auth \
    --auth-flow CUSTOM_AUTH \
    --auth-parameters USERNAME=$USERNAME_ONE \
    --client-id $USER_POOL_CLIENT_ID \
    --region us-east-1)

USER_ONE_TOKEN_RESULTS=$(echo $USER_AUTH | jq '.AuthenticationResult')
USER_ONE_TOKEN=$(echo $USER_ONE_TOKEN_RESULTS | jq --raw-output '.IdToken')

echo $USER_ONE_TOKEN

HELLOWORLD_TEST_URL=$(echo $HELLOWORLD_URL/$USER_ONE_SUB)

curl -i -H "X-Authorization: $USER_ONE_TOKEN" $HELLOWORLD_TEST_URL