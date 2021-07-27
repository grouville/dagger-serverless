package tata

import (
	//"encoding/json"

	"alpha.dagger.io/dagger"
	//"alpha.dagger.io/dagger/op"
	//"alpha.dagger.io/alpine"
	"alpha.dagger.io/aws"

	"github.com/kick-my-sam/serverless"
	"github.com/kick-my-sam/serverless/events"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

TestCodeDirectory: dagger.#Input & {dagger.#Artifact}

TestCodeZip: serverless.#Code & {
	config:  TestConfig
	name:    "myCode"
	source:  TestCodeDirectory
	handler: "lambda-tata"
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
	name: "TataApp"
	config:      TestConfig
	description: "My tata app"
	functions: {
		"Tata": TestFunctionZip
	}
}
