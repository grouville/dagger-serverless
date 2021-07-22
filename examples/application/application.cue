package example

import (
	"encoding/json"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/aws"

	"github.com/kick-my-sam/serverless"
	"github.com/kick-my-sam/serverless/events"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

TestCodeDirectory: dagger.#Input & {dagger.#Artifact}

TestCode: serverless.#Code & {
	name:   "go-cool-func"
	config: TestConfig
	source: TestCodeDirectory
}

TestCode2: serverless.#Code & {
	name:   "go-cool-func-two"
	config: TestConfig
	source: TestCodeDirectory
}

api: events.#Api & {
	path: "/get"
}

queue: events.#SQS & {
	queue: "fake::arn"
}

TestFunctionZip: serverless.#Function & {
	name:    "my-cool-func"
	code:    TestCode
	runtime: "go1.x"
	handler: "index.handler"
	"events": {
		"api":   api
		"queue": queue
		"cat":   events.#Api & {
			path: "/cat"
		}
	}
}

TestFunctionZip2: serverless.#Function & {
	name:    "my-cool-func2"
	code:    TestCode2
	runtime: "go1.x"
	handler: "index.handler"
	"events": {
		"api": events.#Api & {
			"path": "/foo"
		}
		"queue": events.#SQS & {
			queue: "fake::arn"
		}
		"tata": events.#Api & {
			path: "/bar"
		}
	}
}

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

TestApplication: serverless.#Application & {
	config:      TestConfig
	description: "My cool application"
	functions: [TestFunctionZip2, TestFunctionZip]
	api: TestApi
}

result: json.Marshal(TestApplication.#manifest)
