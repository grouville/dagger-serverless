package example

import (
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"

	"github.com/grouville/dagger-serverless/serverless/aws/secretmanager"
	"github.com/grouville/dagger-serverless/serverless"
	"github.com/grouville/dagger-serverless/serverless/events"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

// Secrets to dynamic reference
TestSecrets: secretmanager.#Secrets & {
	config: TestConfig
	secrets: {
		joe:  dagger.#Input
		toto: dagger.#Input
	}
}

// Inlined code to deploy
TestInlineCode: #"""
	    exports.handler = function(event, context, callback) {
	    console.log(event);
	        const response = {
	            statusCode: 200,
	            body: JSON.stringify('Hello Node')
	        };
	        callback(null, response);
	    };
	"""#

// Global Stack and bucket name
TestName: "dagger-test-inline-secret"

// Declare code associated to below func
TestCode: serverless.#Code & {
	config:     TestConfig
	handler:    "index.handler"
	inlineCode: TestInlineCode
	name:       "jsInlineFuncAgain"
	stackName:  TestName
}

// Lambda to deploy
TestFunctionInline: serverless.#Function & {
	code:    TestCode
	runtime: "nodejs12.x"
	secrets: TestSecrets
	"events": {
		api: events.#Api & {
			"path":   "/"
			"method": "get"
		}
	}
}

// Application deploys one or more functions
TestApplication: serverless.#Application & {
	name:        "\(TestName)-deployment"
	config:      TestConfig
	bucket:      TestCode.infra.bucketName
	description: "Test secret env var reference use"
	functions: {
		inline: TestFunctionInline
	}
	global: serverless.#Global
}
