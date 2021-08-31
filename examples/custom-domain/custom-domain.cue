package example

import (
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"

	"github.com/grouville/dagger-serverless/serverless"
	"github.com/grouville/dagger-serverless/serverless/events"
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
TestDNS: dagger.#Input & {*"test.dagger-lambda-example.fr" | string}

// Zone ID
TestZoneId: dagger.#Input & {*"Z01275203OFYU3NA8A9I1" | string}

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
	runtime: "nodejs12.x"
	"events": {
		api: events.#Api & {
			path: "/hello"
		}
	}
}

TestApplication: serverless.#Application & {
	name:        "\(TestStackName)-deployment"
	config:      TestConfig
	bucket:      TestCode.infra.bucketName
	description: "A inlined function with custom domain name"
	functions: {
		InlineFunction: TestFunction
	}
	global: serverless.#Global & {
		"domain": serverless.#Domain & {
			"domain":            TestDNS
			"domainCertificate": "*.dagger-lambda-example.fr"
			"config":            TestConfig
			"hostedZoneId":      TestZoneId
		}
	}
}
