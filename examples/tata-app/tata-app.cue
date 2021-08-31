package example

import (

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

TestCodeZip: serverless.#Code & {
	config:    TestConfig
	name:      "myCode"
	stackName: TestStackName
	source:    TestCodeDirectory
	handler:   "lambda-tata"
}

TestFunctionZip: serverless.#Function & {
	code:    TestCodeZip
	runtime: "go1.x"
	"events": {
		"api": events.#Api & {
			path: "/{proxy+}"
		}
	}
}

TestApplication: serverless.#Application & {
	name:        "TataApp"
	config:      TestConfig
	bucket:      TestCodeZip.infra.bucketName
	description: "My tata app"
	functions: {
		"Tata": TestFunctionZip
	}
}
