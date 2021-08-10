package acm

#_Code: #"""
	# Retrieve certificate
	aws acm list-certificates \
		--query "CertificateSummaryList[].[CertificateArn,DomainName]" \
		--output text | grep "$DOMAIN_NAME" | cut -f1 | tr -d '\n' > /output-arn.txt
"""#