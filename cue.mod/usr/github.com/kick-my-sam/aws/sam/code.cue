package sam

#Code: #"""
	function getOutputs() {
	    aws cloudformation describe-stacks \
	        --stack-name "$STACK_NAME" \
	        --query 'Stacks[].Outputs' \
	        --output json \
	        | jq '.[] | map( { (.OutputKey|tostring): .OutputValue } ) | add' \
	        > /outputs.json
	}

	# Package stack
	aws cloudformation package \
		--template-file /input/template.json \
		--output-template-file output-template.yaml \
		--s3-bucket "$S3_BUCKET"

	# Deploy stack
	aws cloudformation deploy \
		--template-file output-template.yaml \
		--stack-name "$STACK_NAME"
		--capabilities CAPABILITY_IAM

	getOutputs
	"""#
