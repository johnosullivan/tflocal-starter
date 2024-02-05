package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	glambda "github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	slambda "github.com/aws/aws-sdk-go/service/lambda"
	"log"
)

func header() map[string]string {
	headers := make(map[string]string)
	headers["Content-Type"] = "application/json"
	headers["Access-Control-Allow-Origin"] = "*"
	return headers
}

func HandleRequest(ctx context.Context, request *events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	log.Println("Hello World!", request)
	var claimsMap map[string]interface{}
	//var ok bool
	/*if claimsMap, ok = request.RequestContext.Authorizer["claims"].(map[string]interface{}); !ok {
		return events.APIGatewayProxyResponse{
			StatusCode:      401,
			Headers:         header(),
			IsBase64Encoded: false,
		}, errors.New("")
	}*/

	// Create Lambda service client
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	client := slambda.New(sess, &aws.Config{Region: aws.String("us-east-1")})

	payload, err := json.Marshal(request)
	if err != nil {
		return events.APIGatewayProxyResponse{
			StatusCode:      404,
			Headers:         header(),
			IsBase64Encoded: false,
		}, nil
	}

	_, err = client.Invoke(&slambda.InvokeInput{
		FunctionName: aws.String("lambda-function-helloworld-2-default"),
		Payload:      payload,
	})
	if err != nil {
		fmt.Println("Error invoking lambda-function-helloworld-2-default")
		log.Println(err)
		return events.APIGatewayProxyResponse{
			StatusCode:      500,
			Headers:         header(),
			IsBase64Encoded: false,
		}, nil
	}

	message := fmt.Sprintf("Hello %s!", claimsMap["sub"])
	return events.APIGatewayProxyResponse{
		Body:            message,
		StatusCode:      200,
		Headers:         header(),
		IsBase64Encoded: false,
	}, nil
}

func main() {
	glambda.Start(HandleRequest)
}
