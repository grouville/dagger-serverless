package example

import (
	"encoding/json"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/aws"

	"github.com/grouville/dagger-serverless/serverless"
	"github.com/grouville/dagger-serverless/serverless/events"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

TestCodeDirectory: dagger.#Input & {dagger.#Artifact}

TestStackName: dagger.#Input & {*"dagger-serverless-function-test" | string}

TestCode: serverless.#Code & {
	name:      "go-cool-func"
	stackName: TestStackName
	config:    TestConfig
	source:    TestCodeDirectory
	handler:   "index.handler"
}

TestCode2: serverless.#Code & {
	name:      "go-cool-func-two"
	stackName: TestStackName
	config:    TestConfig
	source:    TestCodeDirectory
	handler:   "index.handler"
}

api: events.#Api & {
	path: "/get"
}

queue: events.#SQS & {
	queue: "fake::arn"
}

TestFunctionZip: serverless.#Function & {
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
