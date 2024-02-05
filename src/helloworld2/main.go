package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"log"
)

func header() map[string]string {
	headers := make(map[string]string)
	headers["Content-Type"] = "application/json"
	headers["Access-Control-Allow-Origin"] = "*"
	return headers
}

func HandleRequest(ctx context.Context, request *events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("Hello World! 2", request)

	message := fmt.Sprintf("Hello World! 2!")
	return events.APIGatewayProxyResponse{
		Body:            message,
		StatusCode:      200,
		Headers:         header(),
		IsBase64Encoded: false,
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
