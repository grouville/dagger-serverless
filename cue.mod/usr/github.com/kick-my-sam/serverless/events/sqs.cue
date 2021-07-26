package events

import (
	"alpha.dagger.io/dagger"
)

// Build SQS event for AWS::Serverless::Function
#SQS: {
	// Queue's ARN
	queue: dagger.#Input & {=~"arn:aws:sqs:[\\S]+$"}

	// The maximum number of items to retrieve in a single batch
	batchSize: dagger.#Input & {*10 | number & >=1 & <=10000}

	// Disables the event source mapping to pause polling and invocation
	enabled: dagger.#Input & {*null | bool}

	// The maximum amount of time, in seconds,
	// to gather records before invoking the function
	maximumBatchingWindowInSecond: dagger.#Input & {*null | number & >0}

	#manifest: {
		Type: "SQS"
		Properties: {
			Queue:     queue
			BatchSize: batchSize
			if enabled != null {
				Enabled: enabled
			}
			if maximumBatchingWindowInSecond != null {
				MaximumBatchingWindowInSecond: maximumBatchingWindowInSecond
			}
		}
	}
}
