package serverless

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/aws"
)

// Deploy serverless application to AWS
#Application: {
	// Aws credentials
	config: dagger.#Input & {aws.#Config}

	// Application description
	description: dagger.#Input & {string}

	// Application's functions
	functions: dagger.#Input & {[...#Function]}

	// Application api configuration
	api: dagger.#Input & {*null | #Api}

	#manifest: {
		AWSTemplateFormatVersion: "2010-09-09"
		Transform:                "AWS::Serverless-2016-10-31"
		Description:              description

		Resources: {
			for f in functions {
				"\(f.name)": f.#manifest
			}
			if api != null {
				"\(api.name)": api.#manifest
			}
		}

		Outputs: {
			URL: {
				Description: "API Gateway endpoint URL"
				if api != null {
					Value: "!Sub 'https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/\(api.stage)/'"
				}
				if api == null {
					Value: "!Sub 'https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/Prod/'"
				}
			}
			for f in functions {
				"\(f.name)Function": {
					"Description": "\(f.name) Function ARN"
					"Value":       "!GetAtt \(f.name).Arn"
				}
				"\(f.name)IamRole": {
					"Description": "Implicit IAM Role created for \(f.name) function"
					"Value":       "!GetAtt \(f.name)Role.Arn"
				}
			}
		}
	}
}
