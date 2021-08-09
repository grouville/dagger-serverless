package secretmanager

import (
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/dagger/op"
	"alpha.dagger.io/os"
)

#Secrets: {
	// AWS config credentials
	config: aws.#Config

	// List of encrypted secrets
	secrets: [name=string]: dagger.#Secret

	// Deploy encrypted secrets
	deployment: os.#Container & {
		image: aws.#CLI & {"config": config}
		shell: path: "/bin/bash"
		always: true

		for name, s in secrets {
			secret: "/tmp/secrets/\(name)": s
		}

		command: #command		
	}

	// dynamic references
	references: {
		[string]: string
	}

	references: #up: [
		op.#Load & {
			from: deployment
		},
		op.#Export & {
			source: "/tmp/output.json"
			format: "json"
		},
	]
}
