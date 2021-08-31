// AWS Serverless Application Model (SAM)
package sam

import (
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"
	"github.com/grouville/dagger-serverless/serverless/aws/cloudformation"
)

// Sam template deployment
#SAM: {
	// AWS Config
	config: aws.#Config

	// Name of the stack
	stackName: dagger.#Input & {string}

	// Sam config template
	template: dagger.#Input & {string}

	// S3 bucket uri to store template 
	bucket: dagger.#Input & {=~"^[a-zA-Z-]+$"}

	// Package template with corresponding bucket
	packagedTemplate: #PackagedTemplate & {
		"config":   config
		"template": template
		"bucket":   bucket
	}

	// Deploy template
	deploy: cloudformation.#Stack & {
		"config":    config
		"stackName": stackName
		source:      packagedTemplate.output
	}
}
