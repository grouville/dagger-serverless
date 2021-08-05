package main

import (
	"context"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	chiadapter "github.com/awslabs/aws-lambda-go-api-proxy/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/go-chi/chi/v5"
)

// Lambda
var chiLambda *chiadapter.ChiLambda

// Handle request
func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// If no name is provided in the HTTP request body, throw an error
	return chiLambda.ProxyWithContext(ctx, req)
}

func main() {
	router := chi.NewRouter()
	router.Use(middleware.Logger)

	router.Get("/hello", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello from Dagger serverless"))
	})

	chiLambda = chiadapter.New(router)
	lambda.Start(Handler)
}
