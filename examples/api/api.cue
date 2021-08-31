package example

import (
	"encoding/json"

	"alpha.dagger.io/dagger"

	"github.com/grouville/dagger-serverless/serverless"
)

TestCors: serverless.#Cors & {
	origin: "example.com"
	methods: ["GET", "POST"]
	maxAge: 500
}

TestApi: serverless.#Api & {
	name:  "myCoolApi"
	stage: "Toto"
	cors:  TestCors
}

// From official aws reference
// https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-api.html#sam-api-models
TestApiWithModel: serverless.#Api & {
	name:  "inlineModelApi"
	stage: "Model"
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

output1: dagger.#Output & {json.Marshal(TestApi.#manifest)}
output2: dagger.#Output & {json.Marshal(TestApiWithModel.#manifest)}
