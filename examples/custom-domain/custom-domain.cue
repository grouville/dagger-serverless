package example

import (
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"

	"github.com/dagger-serverless/serverless"
	"github.com/dagger-serverless/serverless/events"
)

// AWS Configuration
TestConfig: aws.#Config & {
	region: "eu-west-3"
}

// Inline function
TestInlineLambdaCode: #"""
	    exports.handler = function(event, context, callback) {
	    console.log(event);
	        const response = {
	            statusCode: 200,
	            body: JSON.stringify('Hello from dagger custom domain')
	        };
	        callback(null, response);
	    };	
	"""#

// Stack name
TestStackName: dagger.#Input & {*"dagger-test-custom-domain" | string}

// Custom domain to use 
TestDNS: dagger.#Input & {*"dagger-lambda-example.fr" | string}

// Deploy code
TestCode: serverless.#Code & {
	config:     TestConfig
	handler:    "index.handler"
	inlineCode: TestInlineLambdaCode
	name:       "lambda-code"
	stackName:  TestStackName
}

TestFunction: serverless.#Function & {
	code:    TestCode
	runTime: "nodejs12.x"
	"events": {
		api: events.#Api & {
			path: "/hello"
		}
	}
}

TestApplication: serverless.#Application & {
	name:        TestStackName
	config:      TestConfig
	bucket:      TestCode.infra.bucketName
	description: "A inlined function with custom domain name"
	function: {
		InlineFunction: TestFunction
	}
}
