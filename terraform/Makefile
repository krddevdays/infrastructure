all: init

init:
	terraform init -backend-config="access_key=${YC_KEY_ID}" -backend-config="secret_key=${YC_KEY_SECRET}"


apply:
	terraform apply terraform.plan

plan:
	terraform plan -out=terraform.plan

destroy:
	terraform destroy
