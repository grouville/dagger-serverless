package serverless

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/docker"
	"alpha.dagger.io/aws"
	"alpha.dagger.io/aws/s3"
	"alpha.dagger.io/aws/ecr"

	"github.com/grouville/dagger-serverless/serverless/zip"
)

// Upload code to s3 or ECR
#Code: {
	// AWS credentials
	config: aws.#Config

	// Source code name
	name: dagger.#Input & {=~"^[a-zA-Z-]+$"}

	// Stack name to upload code
	stackName: dagger.#Input & {=~"^[a-zA-Z-]+$"}

	// Source code of lambda
	source: dagger.#Input & {*null | dagger.#Artifact}

	// Inlined source code of lambda
	inlineCode: *null | string

	// Source type
	type: dagger.#Input & {*"Zip" | "Image"}

	// Dagger serverless infrastructure deployment
	infra: #Stack & {"config": config, name: stackName}

	// Function's handler
	handler: dagger.#Input & {*null | =~"^[\\S]+$"}

	deployment: {
		// If source is an artifact to zip
		if type == "Zip" && source != null && inlineCode == null {
			code: zip.#Zip & {
				"source": source
				"name":   "\(name).zip"
			}

			remoteCode: s3.#Object & {
				always:   true
				"config": config
				"source": code
				"target": infra.bucketUri
			}

			codeUri: dagger.#Output & {"\(remoteCode.url)/\(code.name)"}
		}

		// If source is an artifact to build
		if type == "Image" && source != null && inlineCode == null {
			ref: "\(infra.registryUri):\(name)"

			code: docker.#Build & {"source": source}

			ecrCreds: ecr.#Credentials & {"config": config}

			remoteCode: docker.#Push & {
				"source": code
				"target": ref
				auth: {
					username: ecrCreds.username
					secret:   ecrCreds.secret
				}
			}

			imageUri: dagger.#Output & {"\(remoteCode.ref)"}
		}
	}
}
