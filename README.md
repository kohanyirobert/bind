# About

- Create a GCP project
- Create an _Editor_ service account for Terraform
- Save the JSON file with the account's credentials in a file called `credentials.json`
- `export GOOGLE_CREDENTIALS=credentials.json`
- Create a storage bucket for Terraform to store its state in
- `terraform init -backend-config bucket=<bucket-name>`
- Create an SSH key pair for the Unix user account that'll connect to the machine
- Create a file called `terraform.tfvars` and provide values for the variables in `variables.tf`
- `terraform plan -out last.tfplan`
- `terraform apply last.tfplan && rm last.tfplan`
- `terraform output ip`
- `ssh -i <private-key> <user>@<ip>`
- `terraform destroy`

Note: examin default firewall rules associated with the default VPC since those isn't touched by Terraform.
