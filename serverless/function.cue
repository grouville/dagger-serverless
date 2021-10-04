package serverless

import (
	"alpha.dagger.io/dagger"

	"github.com/grouville/dagger-serverless/serverless/aws/secretmanager"
	"github.com/grouville/dagger-serverless/serverless/events"
)

// Event list
#Event: events.#Api | events.#SQS

// Check if a provided event exists
// in a map of functions
// If exist : res = true else false
#_IsEventInFunctions: {
	type: #Event

	functions: [string]: #Function

	res: *false | bool

	for _, function in functions {
		for _, e in function.events {
			if (e & type) != _|_ {
				res: true
			}
		}
	}
}

// Build AWS::Serverless::Function
#Function: {
	// Function's code
	code: #Code

	// Function's description
	description: dagger.#Input & {*null | string}

	// Runtime to execute function
	runtime: dagger.#Input & {=~"^[\\S]+$"}

	// Memory size
	memorySize: dagger.#Input & {*512 | number & >0}

	// Timeout
	timeout: dagger.#Input & {*60 | number & >0}

	// Tracing
	tracing: dagger.#Input & {*null | "Active" | "PassThrough"}

	// Policies
	policies: dagger.#Input & {*"AWSLambdaBasicExecutionRole" | =~"^[\\S]+$"}

	// Role ARN
	role: dagger.#Input & {*null | string}

	// Environement
	environments: [string]: =~"^[\\S]+$"

	// Secrets variable
	secrets: *null | secretmanager.#Secrets & {"config": code.config}

	// Tags
	tags: [string]: =~"^[\\S]+$"

	// Events
	events: [string]: #Event

	// Layers
	layers: [string]: #Layer

	#manifest: {
		Type: "AWS::Serverless::Function"
		Properties: {
			if code.handler != null {
				Handler: code.handler
			}

			// Add source code
			if code.type == "Zip" && code.source != null && code.inlineCode == null {
				CodeUri: code.deployment.codeUri
			}
			if code.type == "Image" && code.source != null && code.inlineCode == null {
				ImageUri: code.deployment.imageUri
			}
			if code.type == "Zip" && code.inlineCode != null {
				InlineCode: code.inlineCode
			}

			// Configuration
			Runtime:    runtime
			MemorySize: memorySize
			Policies:   policies

			if role != null {
				Role: role
			}

			Timeout:     timeout
			PackageType: code.type
			if description != null {
				Description: description
			}

			if tracing != null {
				Tracing: tracing
			}

			// Add environment and secrets
			Environment: Variables: {
				for key, value in environments {
					"\(key)": value
				}
				if secrets != null {
					for key, value in secrets.references {
						"\(key)": value
					}
				}
			}

			// Tags
			if len(tags) > 0 {
				Tags: {
					for key, value in tags {
						"\(key)": value
					}
				}
			}

			// Layers
			if len(layers) > 0 {
				Layers: [
					for name, _ in layers {
						Ref: name
					},
				]
			}

			// Events
			Events: {
				for name, event in events {
					"\(name)": event.#manifest
				}
			}
		}
	}
}
