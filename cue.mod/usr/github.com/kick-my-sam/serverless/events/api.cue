package events

import (
	"alpha.dagger.io/dagger"
)

// Build API Event for AWS::Serverless::Function
#Api: {
	// HTTP method for which this function is invoked
	method: dagger.#Input & {*"any" | =~"^[a-zA-Z]+$"}

	// Uri path for which this function is invoked.
	// Must start with /
	path: dagger.#Input & {=~"^\/[\\S]*$"}

	// Request parameters configuration
	parameters: dagger.#Input & {[...(
			=~"method.request.header.(.*)" |
		=~"method.request.querystring.(.*)" |
		=~"method.request.path.(.*)"),
	]}

	#manifest: {
		Type: "Api"
		Properties: {
			Path:              path
			Method:            method
			RequestParameters: parameters
		}
	}
}
