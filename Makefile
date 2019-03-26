terraform_new:
	@echo Building terraform 0.12.0 deck
	@md2gslides ./terraform_0_12/terraform.md -t "Terraform 0.12.0" -n -c ${DEFAULT_TEMPLATE} -s atom-one-dark

swim_new:
	@echo Building SWIM deck
	@md2gslides ./swim/swim.md -t "SWIM" -n -c ${DEFAULT_TEMPLATE} -s atom-one-dark

swim_update:
	@echo Building SWIM deck
	@md2gslides ./swim/swim.md -a 1aQCJo3tSjwHEgDOq6kMlIIXjLEVTQa3owCfMacfW9z4 -e -s atom-one-dark
