package example

import (
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"

	"github.com/grouville/dagger-serverless/serverless"
	"github.com/grouville/dagger-serverless/serverless/events"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

TestCodeDirectory: dagger.#Input & {dagger.#Artifact}

TestLayerDirectory: dagger.#Input & {dagger.#Artifact}

TestStackName: dagger.#Input & {*"dagger-layer-app" | string}

TestCode: serverless.#Code & {
	name:      "cloud-lambda"
	stackName: TestStackName
	config:    TestConfig
	source:    TestCodeDirectory
	handler:   "index.lambdaHandler"
}

TestLayerCode: serverless.#Code & {
	name:      "cloud-lambda-layer"
	stackName: TestStackName
	config:    TestConfig
	source:    TestLayerDirectory
}

TestLayer: serverless.#Layer & {
	name: TestLayerCode.name
	runtimes: [ "nodejs10.x"]
	code: TestLayerCode
}

TestFunction: serverless.#Function & {
	code:    TestCode
	runtime: "nodejs10.x"
	"events": {
		"GetTemp": events.#Api & {
			path:   "/{conversion}/{value}"
			method: "get"
		}
	}
	layers: {
		"Package": TestLayer
	}
}

TestApplication: serverless.#Application & {
	config: TestConfig
	name:   "dagger-layer-app-template"
	bucket: TestCode.infra.bucketName
	functions: {
		Temp: TestFunction
	}
}
