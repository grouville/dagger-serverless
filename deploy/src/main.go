package main

import (
	"context"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	chiadapter "github.com/awslabs/aws-lambda-go-api-proxy/chi"
	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
)

var chiLambda *chiadapter.ChiLambda

func Handler(ctx context.Context, req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// If no name is provided in the HTTP request body, throw an error
	return chiLambda.ProxyWithContext(ctx, req)
}

func main() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Get("/tutu", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("welcome Tutu"))
	})
	r.Get("/tyty", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("welcome Tyty"))
	})
	r.Get("/toto", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("welcome Toto"))
	})
	r.Get("/tata", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("welcome Tata"))
	})

	chiLambda = chiadapter.New(r)
	lambda.Start(Handler)
}
