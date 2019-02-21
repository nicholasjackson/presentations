terraform_new:
	@echo Building terraform 0.12.0 deck
	@md2gslides ./terraform_0_12/terraform.md -t "Terraform 0.12.0" -n -c ${DEFAULT_TEMPLATE} -s atom-one-dark
