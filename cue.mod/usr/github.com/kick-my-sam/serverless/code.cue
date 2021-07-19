package serverless

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/docker"
	"alpha.dagger.io/aws"
	"alpha.dagger.io/aws/s3"
	"alpha.dagger.io/aws/ecr"

	"github.com/kick-my-sam/zip"
)

// Upload code to s3 or ECR
#Code: {
	// AWS credentials
	config: dagger.#Input & {aws.#Config}

	// Source code name
	name: dagger.#Input & {=~"^[a-zA-Z-]+$"}

	// Source code of lambda
	source: dagger.#Input & {dagger.#Artifact | string}

	// Source type
	type: dagger.#Input & {*"Zip" | "Image"}

	// Dagger serverless infrastructure deployment
	infra: #Stack & {"config": config}

	deployment: {
		// If source is an artifact to zip
		if type == "Zip" && (source & string) == _|_ {
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
		if type == "Image" && (source & string) == _|_ {
			ref: "\(infra.registoryUri):\(name)"

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
