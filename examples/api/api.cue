package example

import (
	"github.com/kick-my-sam/serverless"
)

TestCors: serverless.#Cors & {
	origin:  "example.com"
	methods: "GET"
	maxAge:  500
}

TestApi: serverless.#Api & {
	name:  "my-cool-api"
	stage: "Toto"
	cors:  TestCors
}

// From official aws reference
// https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-api.html#sam-api-models
TestApiWithModel: serverless.#Api & {
	name: "inline-model-api"
	models: {
		User: serverless.#Model & {
			type: "object"
			required: ["username", "employee_id"]
			properties: {
				username: type:    "string"
				employee_id: type: "integer"
				department: type:  "string"
			}
		}
		Item: serverless.#Model & {
			type: "object"
			properties: {
				count:
					type: "integer"
				category:
					type: "string"
				price:
					type: "integer"
			}
		}
}
}