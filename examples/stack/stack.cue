package example

import (
	"alpha.dagger.io/aws"
	"github.com/kick-my-sam/serverless"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

TestStack: serverless.#Stack & {
	config: TestConfig
}
