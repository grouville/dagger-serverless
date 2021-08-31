package example

import (
	"alpha.dagger.io/alpine"
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/os"

	"github.com/grouville/dagger-serverless/serverless/aws/secretmanager"
)

TestConfig: aws.#Config & {
	region: "eu-west-3"
}

TestStack: secretmanager.#Secrets & {
	config: TestConfig
	secrets: {
		joe:  dagger.#Input
		toto: dagger.#Input
	}
}

TestReferences: os.#Container & {
	image: alpine.#Image & {
		package: bash: "=5.1.0-r0"
	}
	shell: path: "/bin/bash"
	always: true

	command: #"""
		    # Iterate on env var, split them and check that substr is present
		    env | grep ref | while IFS= read -r line; do
		        value=${line#*=}
		        [[ "$value" == *"resolve:secretsmanager"* ]]
		    done
		"""#

	for key, value in TestStack.references {
		env: "ref\(key)": value
	}
}
