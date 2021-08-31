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
	config: aws.#Config

	// Stack name
	name: dagger.#Input & {=~"^[a-zA-Z-]+$"}

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
					BucketName: "\(name)-bucket"
					Tags: [{
						Key:   "dagger"
						Value: "serverless"
					}]
				}
			}
			Registry: {
				Type: "AWS::ECR::Repository"
				Properties: {
					RepositoryName: "\(name)-registry"
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
			BucketURI: {
				Value: {"Ref": "Bucket"}
			}
			BucketName: Value:     "\(name)-bucket"
			RepositoryName: Value: "\(name)-registry"
		}
	})

	cfn: cloudformation.#Stack & {
		"config":  config
		source:    #template
		stackName: name
	}

	// ECR Repository URI
	registryUri: dagger.#Output & {string}
	registryUri: cfn.outputs.RegistryURI

	// S3 bucket URI
	bucketUri: dagger.#Output & {string}
	bucketUri: "s3://\(cfn.outputs.BucketURI)"

	// S3 bucket name
	bucketName: dagger.#Output & {string}
	bucketName: cfn.outputs.BucketName

	// ECR repository name
	registryName: dagger.#Output & {string}
	registryName: cfn.outputs.RepositoryName
}
