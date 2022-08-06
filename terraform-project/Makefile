virginia:
		terraform workspace new virginia || terraform workspace select virginia
		terraform init
		terraform apply -var-file envs/virginia.tfvars -auto-approve
iowa:
		terraform workspace new iowa ||terraform workspace select iowa
		terraform init
		terraform apply -var-file envs/iowa.tfvars -auto-approve
losangeles:
		terraform workspace new losangeles || terraform workspace select losangeles
		terraform init
		terraform apply -var-file envs/losangeles.tfvars -auto-approve
lasvegas:
		terraform workspace new lasvegas || terraform workspace select lasvegas
		terraform init
		terraform apply -var-file envs/lasvegas.tfvars -auto-approve		

################################################################################################

destroy-virginia:
		terraform workspace new virginia || terraform workspace select virginia
		terraform init
		terraform destroy -var-file envs/virginia.tfvars -auto-approve
destroy-iowa:
		terraform workspace new iowa ||terraform workspace select iowa
		terraform destroy -var-file envs/iowa.tfvars -auto-approve
losangeles:
		terraform workspace new losangeles || terraform workspace select losangeles
		terraform destroy -var-file envs/losangeles.tfvars -auto-approve
lasvegas:
		terraform workspace new lasvegas || terraform workspace select lasvegas
		terraform destroy -var-file envs/lasvegas.tfvars -auto-approve
