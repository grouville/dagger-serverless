package example

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/aws"

	"github.com/kick-my-sam/serverless"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

TestCodeDirectory: dagger.#Input & {dagger.#Artifact}

TestCodeZip: serverless.#Code & {
	config:  TestConfig
	name:    "go-cool-func"
	source:  TestCodeDirectory
	handler: "index.handler"
}

TestImageDirectory: dagger.#Input & {dagger.#Artifact}

TestCodeImage: serverless.#Code & {
	config:  TestConfig
	name:    "go-cool-image"
	source:  TestImageDirectory
	type:    "Image"
	handler: "index.handler"
}
