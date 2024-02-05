SHELL := /bin/bash

all: tidy 

tidy:
	go mod tidy

lint-pre:
	@test -z $(gofmt -l .)
	@go mod verify

lint: lint-pre
	@golangci-lint run

lint-verbose: lint-pre
	@golangci-lint run -v --timeout=5m

dynamodb:
	@docker run -p 8000:8000 -d --name dynamodb amazon/dynamodb-local
	
tests:
	@go test -v -race -coverprofile .testCoverage.txt ./... -p 1

build:
	@mkdir -p bin/helloworld/
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bin/helloworld/helloworld helloworld/main.go
	@mkdir -p bin/helloworld2/
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bin/helloworld2/helloworld2 helloworld2/main.go
	
.PHONY: