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
	name:    "go-cool-func"
	config:  TestConfig
	source:  TestCodeDirectory
	handler: "index.handler"
}

TestCode2: serverless.#Code & {
	name:    "go-cool-func-two"
	config:  TestConfig
	source:  TestCodeDirectory
	handler: "index.handler"
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

output:  dagger.#Output & {json.Marshal(TestFunctionZip.#manifest)}
output2: dagger.#Output & {json.Marshal(TestFunctionZip2.#manifest)}
