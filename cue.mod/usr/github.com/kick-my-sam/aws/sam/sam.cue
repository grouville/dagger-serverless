// AWS Serverless Application Model (SAM)
package sam

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/dagger/op"
	"alpha.dagger.io/aws"
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

	outputs: [string]: string & dagger.#Output
	outputs: #up: [
		op.#Load & {
			from: aws.#CLI & {
				"config": config
			}
		},

		op.#Mkdir & {
			path: "/input"
		},

		op.#WriteFile & {
			dest:    "/input/template.json"
			content: template
		},

		op.#WriteFile & {
			dest:    "/entrypoint.sh"
			content: #Code
		},

		op.#Exec & {
			always: true
			args: [
				"/bin/bash",
				"--noprofile",
				"--norc",
				"-eo",
				"pipefail",
				"/entrypoint.sh",
			]
			env: {
				STACK_NAME: stackName
				S3_BUCKET:  bucket
			}
		},

		op.#Export & {
			source: "/outputs.json"
			format: "json"
		},
	]
}
