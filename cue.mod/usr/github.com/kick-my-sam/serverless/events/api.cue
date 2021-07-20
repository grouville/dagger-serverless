package events

import (
	"alpha.dagger.io/dagger"
)

// Build API Event for AWS::Serverless::Function
#Api: {
	// HTTP method for which this function is invoked
	method: *"any" | string

	// Uri path for which this function is invoked.
	// Must start with /
	path: dagger.#Input & {=~"^\/(.*)"}

	// Request parameters configuration
	parameters: [...string]

	#manifest: {
		Type: "Api"
		Properties: {
			Path:              path
			Method:            method
			RequestParameters: parameters
		}
	}
}
