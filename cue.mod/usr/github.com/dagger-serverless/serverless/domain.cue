package serverless

import (
	"alpha.dagger.io/dagger"

	"github.com/dagger-serverless/aws/acm"
)

// Configure custom domain for labmda http endpoint
#Domain: {
	// The custom domain name for your API Gateway API
	// Uppercase are not supported
	domain: dagger.#Input & {=~"^([^A-Z][\\S])+$"}

	// A list of the basepaths to configure with the Amazon API Gateway domain name.
	basePath: *["/"] | [string, ...string]

	// Certificate ARN
	// Retrieve automaticaly
	certificate: acm.#Certificate & {
		"domain": domain
	}

	// Defines the type of API Gateway endpoint to map to the custom domain
	endpointConfiguration: *"REGIONAL" | "EDGE"

	// The TLS version plus cipher suite for this domain name
	securityPolicy: *null | string

	#manifest: {
		DomaineName:           domain
		CertificateARN:        certificate.arn
		EndpointConfiguration: endpointConfiguration
		BasePath:              basePath

		if securityPolicy != null {
			SecurityPolicy: securityPolicy
		}
	}
}
