package example

import (
	"alpha.dagger.io/aws"
	"github.com/dagger-serverless/serverless"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

TestStack: serverless.#Stack & {
	config: TestConfig
	name: "dagger-test-stack-serverless"
}
