package sam

#Code: #"""
	# Package stack
	aws cloudformation package \
	    --template-file /input/template.json \
	    --output-template-file /input/output-template.json \
	    --s3-bucket "$S3_BUCKET"
	"""#
