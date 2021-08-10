package acm

import (
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/dagger/op"
)

// Retrieve the certificate ARN from domain name
#Certificate: {
	// AWS credential
	config: aws.#Config

	// Domain name
	domain: dagger.#Input & {=~"^[^A-Z]+$"}

	// Certificate ARN
	arn: dagger.#Output & {
		string
		#up: [
			op.#Load & {
				from: aws.#CLI & {
					"config": config
				}
			},

			op.#WriteFile & {
				dest:    "/entrypoint.sh"
				content: #_Code
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
				env: DOMAIN_NAME: domain
			},

			op.#Export & {
				source: "/output-arn.txt"
				format: "string"
			},
		]
	}
}
