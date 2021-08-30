package serverless

import (
	"alpha.dagger.io/dagger"
)

// Build AWS::Serverless::LayerVersion
#Layer: {
	// List of runtimes compatible with this LayerVersion
	runtimes: [=~"^[\\S]+$", ...=~"^[\\S]+$"]

	// Layer's code 
	code: #Code

	// Layer's name
	name: dagger.#Input & {*null | =~"^[\\S]+$"}

	// Layer's description
	description: dagger.#Input & {*null | string}

	// Layer's license
	license: dagger.#Input & {*null | string}

	retentionPolicy: dagger.#Input & {*null | "Retain" | "Delete"}

	#manifest: {
		Type: "AWS::Serverless::LayerVersion"
		Properties: {
			if name != null {
				LayerName: name
			}
			if description != null {
				Description: description
			}
			if code.type == "Zip" && code.source != null {
				ContentUri: code.deployment.codeUri
			}
			CompatibleRuntimes: runtimes
			if license != null {
				LicenseInfo: license
			}
			if retentionPolicy != null {
				RetentionPolicy: retentionPolicy
			}
		}
	}
}
