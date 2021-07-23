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
	name:    "go-cool-func"
	config:  TestConfig
	source:  TestCodeDirectory
	handler: "lambda-tata"
}

TestCode2: serverless.#Code & {
	name:    "go-cool-func-two"
	config:  TestConfig
	source:  TestCodeDirectory
	handler: "lambda-tata"
}

TestFunctionZip: serverless.#Function & {
	name:    "myCoolFunc"
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
	name:    "myCoolFunc2"
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
	methods: "GET"
	maxAge:  500
}

TestApplication: serverless.#Application & {
	config:      TestConfig
	description: "My cool application"
	functions: [TestFunctionZip2, TestFunctionZip]
	global: serverless.#Global & {cors: TestCors}
}
