package test

import (
	"encoding/json"

	"alpha.dagger.io/dagger"
	"alpha.dagger.io/random"
	"alpha.dagger.io/aws"
	"alpha.dagger.io/aws/s3"
	// "alpha.dagger.io/aws/ecr"
	// "alpha.dagger.io/docker"
	"example.com/zip"
)

// Upload code to S3 / ECR
#Code: {
	awsConfig: aws.#Config

	source: dagger.#Input & { dagger.#Artifact | string }

	// Form of lambda
	type: *"Zip" | "Image" & dagger.#Input

	// Target of the bucket [s3://\(bucket)/] or the ECR repository [URI]
	target: string & dagger.#Input

	deployment: {
		suffix: random.#String & {
			seed: ""
		}

		if type == "Zip" {
			if (source & string) == _|_ {
				// Zip code
				zipDir: zip.#Zip & {
					"source": source
					name:   "archive-\(suffix.out).zip"
				}

				// Upload it
				s3Upload: s3.#Object & {
					always:   true
					config:   awsConfig
					"source":   zipDir
					"target": target
				}

				// Output value
				codeUri: "\(s3Upload.url)/\(zipDir.name)"
			}
		}

		if type == "Image" {
			ref: "\(target):\(suffix.out)"

			// artifact: docker.#Build & {
			// 	"source": source
			// }
			// ecrLogin: ecr.#Credentials & {
			// 	config: awsConfig
			// }
			// ecrUpload: docker.#Push & {
			// 	"source":   artifact
			// 	"target": ref
			// 	auth: {
			// 		username: ecrLogin.username
			// 		secret:   ecrLogin.secret
			// 	}
			// }
			// imageUri: "\(ecrUpload.ref)"
			imageUri: "toto"
		}
	}
}

// AWS::Serverless::Function Resource construction
#Function: {
	name: string & dagger.#Input

	code: #Code

	// handler: string & dagger.#Input

	runtime: string & dagger.#Input

	memorySize: *512 | number & dagger.#Input

	timeout: *60 | number & dagger.#Input

	tracing: *null | "Active" | "PassThrough" & dagger.#Input

	policies: *"AWSLambdaBasicExecutionRole" | string & dagger.#Input

	cors: [string]: string & dagger.#Input

	environments: [string]: string & dagger.#Input

	tags: [string]: string & dagger.#Input

	path: string

	// Build Resource in manifest
	#manifest: json.Marshal({
		Type: "AWS::Serverless::Function"
		Properties: {
			// if handler != null {
			// 	Handler: handler
			// }
			if code.type == "Zip" && (code.source & string) == _|_ {
				CodeUri: code.deployment.codeUri
			}
			if code.type == "Image" {
				ImageUri: code.deployment.imageUri
			}
			Runtime:     runtime
			MemorySize:  memorySize
			Policies:    policies
			Timeout:     timeout
			PackageType: code.type
			if (code.source & string) != _|_ {
				InlineCode: code.source
			}

			Events: {
				"\(name)": {
					Type: "Api"
					Properties: {
						Path:   path
						Method: "any"
					}
				}
			}

			if tracing != null {
				Tracing: tracing
			}

			if len(environments) > 0 {
				Environment: {
					Variables: {
						for key, value in environments {
							"\(key)": value
						}
					}
				}
			}

			if len(tags) > 0 {
				Tags: {
					for key, value in tags {
						"\(key)": value
					}
				}
			}

			if len(cors) > 0 {
				Api: {
					Cors: {
						for key, value in cors {
							"\(key)": value
						}
					}
				}
			}
		}
	})
}

// Deploy a lamda function to aws s3
#Application: {
	// AWS Config
	// =Profil & region
	awsConfig: aws.#Config & dagger.#Input

	// Description of the lambdas
	description: string & dagger.#Input

	// All the Lambdas
	// =functions
	functions: [...#Function]

	manifest: json.Marshal({
		AWSTemplateFormatVersion: "2010-09-09"
		Transform:                "AWS::Serverless-2016-10-31"
		Description:             description

		Resources: {
			for f in functions {
				"\(f.name)": json.Unmarshal(f.#manifest)
			}
		}

		Outputs: {
			URL: {
				Description: "API Gateway endpoint URL for Prod environment for Functions"
				Value:       "!Sub 'https://${ServerlessRestApi}.execute-api.${AWS::Region}.amazonaws.com/Prod/'"
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
	})
}

func1: #Function & {
	name:    "f1"
	runtime: "go1.x"
	// handler: "lambda-tata"
	code:    #Code & {
		"awsConfig": awsConfig
		target: "s3://bucket-template-sam"
		type: "Zip"
	}
}

func2: #Function & {
	name:    "f2"
	runtime: "python3.7"
	// trigger: {
		// type: "http"
		// path: // À modifier
	// }
	// handler:  "index.handler"
	code:    #Code & {
		"awsConfig": awsConfig
		type: "Image"
		target: "817126022176.dkr.ecr.eu-west-3.amazonaws.com/bucket-template-sam"
	}
}

awsConfig: aws.#Config

app: #Application & {
	//domain: string ==> Mapper 

	"awsConfig": awsConfig
	// functions: [func1, func2]
	functions: [func2]

	//outputs:
	// app.cloudformationStack <==
	// app.s3bucket <== bucket S3 généré / soit donné
	// app.functionsURLs <== list des urls montés par nos fonctions
}

// res: json.Unmarshal(app.manifest)
