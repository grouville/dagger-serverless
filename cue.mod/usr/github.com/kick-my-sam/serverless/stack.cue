package serverless

import (
	"encoding/json"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/aws"
	"alpha.dagger.io/aws/cloudformation"
)

// Create infrastructure
#Stack: {
	// AWS config credentials
	config: dagger.#Input & {aws.#Config}

	// Stack name
	name: *"dagger-serverless" | string

	// S3 bucket name
	bucketName: *"dagger-serverless-bucket" | string

	// ECR repository name
	registryName: *"dagger-serverless-registry" | string

	#template: json.Marshal({
		AWSTemplateFormatVersion: "2010-09-09"
		Description: """
			Dagger serverless stack template compose of:
				- AWS S3 bucket: store lambda program and cloud formation stack
				- AWS ECR: store lambda image
			"""
		Resources: {
			Bucket: {
				Type: "AWS::S3::Bucket"
				Properties: {
					BucketName: bucketName
					Tags: [{
						Key:   "dagger"
						Value: "serverless"
					}]
				}
			}
			Registry: {
				Type: "AWS::ECR::Repository"
				Properties: {
					RepositoryName: registryName
					Tags: [{
						Key:   "dagger"
						Value: "serverless"
					}]
				}
			}
		}
		Outputs: {
			RegistryURI: {
				Value: {
					"Fn::GetAtt": [
						"Registry",
						"RepositoryUri",
					]
				}
			}
		}
	})

	cfn: cloudformation.#Stack & {
		"config":  config
		source:    #template
		stackName: name
	}

	// ECR Repository URI
	registoryUri: dagger.#Output & {string}
	registoryUri: cfn.outputs.RegistryURI

	// S3 bucket URI
	bucketUri: dagger.#Output & {string}
	bucketUri: "s3://\(bucketName)"
}