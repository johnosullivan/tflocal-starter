package main

import (
	"context"
	"errors"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func header() map[string]string {
	headers := make(map[string]string)
	headers["Content-Type"] = "application/json"
	headers["Access-Control-Allow-Origin"] = "*"
	return headers
}

func HandleRequest(ctx context.Context, request *events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	if request == nil {
		return events.APIGatewayProxyResponse{
			Body:            string("bytesResponse"),
			StatusCode:      404,
			Headers:         header(),
			IsBase64Encoded: false,
		}, errors.New("bad request")
	}
	log.Println("Hello World!", request)
	var claimsMap map[string]interface{}
	var ok bool
	if claimsMap, ok = request.RequestContext.Authorizer["claims"].(map[string]interface{}); !ok {
		return events.APIGatewayProxyResponse{
			StatusCode:      401,
			Headers:         header(),
			IsBase64Encoded: false,
		}, errors.New("bad request")
	}
	if sub, ok := claimsMap["sub"].(string); !ok {
		message := fmt.Sprintf("Hello %s!", sub)
		return events.APIGatewayProxyResponse{
			Body:            message,
			StatusCode:      200,
			Headers:         header(),
			IsBase64Encoded: false,
		}, nil
	} else {
		return events.APIGatewayProxyResponse{
			StatusCode:      404,
			Headers:         header(),
			IsBase64Encoded: false,
		}, errors.New("bad request")
	}
}

func main() {
	lambda.Start(HandleRequest)
}
