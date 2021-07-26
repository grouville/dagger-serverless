package serverless

import (
	"alpha.dagger.io/dagger"
	"github.com/kick-my-sam/serverless/events"
)

// Event list
#Event: events.#Api | events.#SQS

// Build AWS::ServerlessFunction
#Function: {
	// Function's code
	code: #Code

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

	// Environement
	environments: [string]: =~"^[\\S]+$"

	// Tags
	tags: [string]: =~"^[\\S]+$"

	// Events
	events: [string]: #Event

	#manifest: {
		Type: "AWS::Serverless::Function"
		Properties: {
			if code.handler != null {
				Handler: code.handler
			}

			// Add source code
			if code.type == "Zip" && (code.source & string) == _|_ {
				CodeUri: code.deployment.codeUri
			}
			if code.type == "Image" && (code.source & string) == _|_ {
				ImageUri: code.deployment.imageUri
			}
			if code.type == "Zip" && (code.source & string) != _|_ {
				InlineCode: code.source
			}

			// Configuration
			Runtime:     runtime
			MemorySize:  memorySize
			Policies:    policies
			Timeout:     timeout
			PackageType: code.type
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

			// Events
			Events: {
				for name, event in events {
					"\(name)": event.#manifest
				}
			}
		}
	}
}
