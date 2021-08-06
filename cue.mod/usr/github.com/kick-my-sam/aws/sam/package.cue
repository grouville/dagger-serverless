package sam

import (
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/dagger/op"
)

// Package Cloudformation Template
#PackagedTemplate: {
	// AWS Config
	config: aws.#Config

	// Sam config template
	template: dagger.#Input & {string}

	// S3 bucket uri to store template 
	bucket: dagger.#Input & {=~"^[a-zA-Z-]+$"}

	output: {
		string

		#up: [
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
				env: S3_BUCKET: bucket
			},

			op.#Export & {
				source: "/input/output-template.json"
				format: "string"
			},
		]
	}
}
