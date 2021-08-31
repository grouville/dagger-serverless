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

TestStackName: dagger.#Input & {*"dagger-serverless-application-test" | string}

TestCode: serverless.#Code & {
	name:      "go-cool-func"
	stackName: TestStackName
	config:    TestConfig
	source:    TestCodeDirectory
	handler:   "lambda-tata"
}

TestCode2: serverless.#Code & {
	name:      "go-cool-func-two"
	stackName: TestStackName
	config:    TestConfig
	source:    TestCodeDirectory
	handler:   "lambda-tata"
}

TestFunctionZip: serverless.#Function & {
	code:    TestCode
	runtime: "go1.x"
	"events": {
		"api": events.#Api & {
			path: "/tyty"
		}
		"cat": events.#Api & {
			path: "/tutu"
		}
	}
}

TestFunctionZip2: serverless.#Function & {
	code:    TestCode2
	runtime: "go1.x"
	"events": {
		"api": events.#Api & {
			"path":   "/toto"
			"method": "get"
		}
		"tata": events.#Api & {
			path: "/tata"
		}
	}
}

TestCors: serverless.#Cors & {
	origin:  "*"
	methods: ["GET"]
	maxAge:  500
}

TestApplication: serverless.#Application & {
	config:      TestConfig
	description: "My cool application"
	bucket:      TestCode.infra.bucketName
	functions: {
		myCoolFunc:  TestFunctionZip
		myCoolFunc2: TestFunctionZip2
	}
	global: serverless.#Global & {cors: TestCors}
}
