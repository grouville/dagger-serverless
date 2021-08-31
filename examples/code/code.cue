package example

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/aws"

	"github.com/grouville/dagger-serverless/serverless"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

TestCodeDirectory: dagger.#Input & {dagger.#Artifact}

TestCodeZip: serverless.#Code & {
	config:    TestConfig
	name:      "goCoolFunc"
	stackName: "dagger-zip-code-test"
	source:    TestCodeDirectory
	handler:   "index.handler"
}

TestImageDirectory: dagger.#Input & {dagger.#Artifact}

TestCodeImage: serverless.#Code & {
	config:    TestConfig
	name:      "goCoolImage"
	stackName: "dagger-image-code-test"
	source:    TestImageDirectory
	type:      "Image"
	handler:   "index.handler"
}

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

TestCodeInline: serverless.#Code & {
	name:       "jsInlineFunc"
	stackName:  "dagger-inlinecode-test"
	config:     TestConfig
	inlineCode: TestInlineCode
	handler:    "index.handler"
}
