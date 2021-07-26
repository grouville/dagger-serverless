package serverless

import (
	"encoding/json"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/aws"

	"github.com/kick-my-sam/aws/sam"
)

#Global: {
	timeout: dagger.#Input & {*null | number & >0}

	cors: *null | #Cors

	#manifest: {
		if timeout != null {
			Function: Timeout: timeout
		}

		if cors != null {
			Api: {
				// Cors
				if (cors & string) != _|_ {
					Cors: cors
				}
				if (cors & string) == _|_ {
					Cors: cors.#manifest
				}
			}
		}
	}
}

// Deploy serverless application to AWS
#Application: {
	// Aws credentials
	config: aws.#Config

	// Application name
	name: dagger.#Input & {*"dagger-serverless-application" | =~"^[a-zA-Z-]+$"}

	// Application description
	description: dagger.#Input & {string}

	// Application's functions
	functions: [=~"^[a-zA-Z0-9]*$"]: #Function

	// Application api configuration
	api: *null | #Api

	// Global application configuration
	global: *null | #Global

	// S3 bucket uri to store application template
	bucket: dagger.#Input & {*"s3://dagger-serverless-bucket" | =~"^s3:\/\/(.*)"}

	#manifest: {
		AWSTemplateFormatVersion: "2010-09-09"
		Transform:                "AWS::Serverless-2016-10-31"
		Description:              description

		if global != null {
			Globals: global.#manifest
		}

		Resources: {
			for name, f in functions {
				"\(name)": {
					f.#manifest

					if api != null {
						RestApiId: "!Ref \(api.name)"
					}
				}
			}
			if api != null {
				"\(api.name)": api.#manifest
			}
		}

		Outputs: {
			URL: {
				Description: "API Gateway endpoint URL"
				if api != null {
					Value: "Fn::Sub": "https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/\(api.stage)/"
				}
				if api == null {
					Value: "Fn::Sub": "https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/Prod/"
				}
			}
			for name, f in functions {
				"\(name)Function": {
					"Description": "\(name) Function ARN"
					"Value": "Fn::GetAtt": ["\(name)", "Arn"]
				}
				"\(name)IamRole": {
					"Description": "Implicit IAM Role created for \(name) function"
					"Value": "Fn::GetAtt": ["\(name)Role", "Arn"]
				}
			}
		}
	}

	deployment: sam.#SAM & {
		"config":  config
		stackName: name
		template:  json.Marshal(#manifest)
		"bucket":  bucket
	}
}
