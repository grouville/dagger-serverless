package example

import (
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
	config: TestConfig
	source: TestCodeDirectory
}

TestFunctionZip: serverless.#Function & {
	name:    "my-cool-func"
	code:    TestCode
	runtime: "go1.x"
	handler: "index.handler"
	"events": {
		"Api": events.#Api & {
			path: "/get"
		}
		"Queue": events.#SQS & {
			queue: "test::arn"
		}
	}
}
