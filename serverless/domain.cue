package serverless

import (
	"alpha.dagger.io/aws"
	"alpha.dagger.io/dagger"

	"github.com/grouville/dagger-serverless/serverless/aws/acm"
)

// Configure custom domain for labmda http endpoint
#Domain: {
	// AWS Credentials
	config: aws.#Config

	// The custom domain name for your API Gateway API
	// Uppercase are not supported
	domain: dagger.#Input & {=~"^[^A-Z]+$"}

	// A list of the basepaths to configure with the Amazon API Gateway domain name.
	// basePath: *["/"] | [string, ...string] -> performance issue
	basePath: *null | [string, ...string]

	// The domain certificate
	// By default: the domain
	domainCertificate: dagger.#Input & {*domain | string}

	// Hosted Zone Id to create Route53 record
	hostedZoneId: dagger.#Input & {string}

	// Certificate ARN
	// Retrieve automaticaly
	certificate: acm.#Certificate & {
		"domain": domainCertificate
		"config": config
	}

	// Defines the type of API Gateway endpoint to map to the custom domain
	endpointConfiguration: *"REGIONAL" | "EDGE"

	// The TLS version plus cipher suite for this domain name
	securityPolicy: *null | string

	#manifest: {
		DomainName:            domain
		CertificateArn:        certificate.arn
		EndpointConfiguration: endpointConfiguration
		Route53: HostedZoneId: hostedZoneId
		if basePath == null {
			BasePath: ["/"]
		}
		if basePath != null {
			BasePath: basePath
		}

		if securityPolicy != null {
			SecurityPolicy: securityPolicy
		}
	}
}
