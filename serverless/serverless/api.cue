package serverless

import (
	"strings"

	"alpha.dagger.io/dagger"
)

// Available http methods
#HttpMethod: "GET" | "HEAD" | "POST" | "PUT" |
	"DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH"

#Cors: {
	// String of origin to allow
	origin: dagger.#Input & {=~"^[\\S]+$"}

	// String of headers to allow
	// E.g ["X-Forwarded-For", "content-type"]
	headers: [...=~"^[\\S]+$"]

	// String containing the HTTP methods to allow
	// E.g ["GET", "POST"]
	methods: [...#HttpMethod]

	// String containing the number of seconds to cache CORS Preflight reques
	maxAge: dagger.#Input & {*null | number & >0}

	// Boolean indicating whether request is allowed to contain credentials.
	credentials: dagger.#Input & {*null | bool}

	#manifest: {
		AllowOrigin: "'\(origin)'"
		if len(methods) > 0 {
			AllowMethods: "'\(strings.Join(methods, ", "))'"
		}
		if len(headers) > 0 {
			AllowHeaders: "'\(strings.Join(headers, ", "))'"
		}
		if maxAge != null {
			MaxAge: "'\(maxAge)'"
		}
		if credentials != null {
			AllowCredentials: credentials
		}
	}
}

#Model: {
	// Model data types
	type: =~"^[\\S]+$"

	// Required field
	required: [...string]

	// Model properties
	properties: [string]: type: string
}

// Build AWS::Serverless::API
#Api: {
	// A name for the API Gateway RestApi resource
	name: dagger.#Input & {=~"^[a-zA-Z0-9]*$"}

	// The name of the stage, which API Gateway uses
	// as the first path segment in the URI
	stage: dagger.#Input & {=~"^[\\S]+$"}

	// Manage Cross-origin resource sharing
	// Specify the domain to allow as a string or specify a dictionary
	// with additional Cors configuration
	cors: dagger.#Input & {*null | string | #Cors}

	// OpenAPI specification that describes your API
	definitionBody: dagger.#Input & {*null | string}

	// Amazon S3 Uri of the OpenAPI document defining the API
	definitionUri: dagger.#Input & {*null | string}

	// API resources tags
	tags: [string]: string

	// The schemas to be used by your API methods.
	models: [string]: #Model

	#manifest: {
		Type: "AWS::Serverless::Api"
		Properties: {
			StageName: stage
			Name:      name

			// Cors
			if cors != null {
				if (cors & string) != _|_ {
					Cors: cors
				}
				if (cors & string) == _|_ {
					Cors: cors.#manifest
				}
			}

			// API Definition
			if definitionBody != null {
				DefinitionBody: definitionBody
			}
			if definitionUri != null {
				DefinitionUri: definitionUri
			}

			// Models
			if len(models) > 0 {
				Models: {
					for key, value in models {
						"\(key)": value
					}
				}
			}

			// Tags
			if len(tags) > 0 {
				Tags: {
					for key, value in tags {
						"\(key)": value
					}
				}
			}
		}
	}
}
