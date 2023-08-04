# Infrastructure as Code
Infrastructure as code of an EC2 instance meant for running a VPN that's useful for accessing machines behind a NAT Firewall (not redirecting all internet traffic).

- [Instructions](#instructions)
    - [Install Terraform](#install-terraform)
    - [Generate SSH key pair](#generate-ssh-key-pair)
    - [Configure variables for running Terraform](#configure-variables-for-running-terraform)
    - [Initialize terraform if it isn't initialized yet](#initialize-terraform-if-it-isnt-initialized-yet)
    - [Create all instance related resources](#create-all-instance-related-resources)
    - [SSH into the instance](#ssh-into-the-instance)
    - [Destroy the instance and everything created with it (optional)](#destroy-the-instance-and-everything-created-with-it-optional)


## Instructions

#### Install Terraform
Terraform is required to run the following instructions. It can be [installed](https://developer.hashicorp.com/terraform/downloads), or used from [Docker](https://hub.docker.com/r/hashicorp/terraform/).

#### Generate SSH key pair
The following command will generate two files. The .pub file content should be passed as the input variable "default_ssh_public_key" to the "create_instance.tf" script, which will copy the public key to the EC2 instance. The other file should be used to SSH into the instance.

```
ssh-keygen -t rsa -b 4096
```

#### Configure variables for running Terraform
Fill the empty variables. Substitute "/path/to/file.pub" with the appropriate path to the SSH public key. The environment variables will only last while the terminal session lasts.

```
# SSH key
export TF_VAR_default_ssh_key_name=""
export TF_VAR_default_ssh_public_key=$(cat /path/to/file.pub)

# Terraform may look for these environment variables
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_SESSION_TOKEN=""

# Used as input variables for the ".tf" files
export TF_VAR_aws_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_aws_secret_key=$AWS_SECRET_ACCESS_KEY
export TF_VAR_aws_session_token=$AWS_SESSION_TOKEN

# More variables at "variables.tf" file
```

If using Terraform in Docker, just follow the previous step, then use the following template to run terraform commands. It's possible to substitute "init" with "plan", "apply", "apply --auto-approve", etc.

```
docker run --rm -it \
           -v ${PWD}:/current_dir -w /current_dir \
           --user "$(id -u):$(id -g)" \
           -e "TF_VAR_aws_access_key=${TF_VAR_aws_access_key}" \
           -e "TF_VAR_aws_secret_key=${TF_VAR_aws_secret_key}" \
           -e "TF_VAR_aws_session_token=${TF_VAR_aws_session_token}" \
           -e "TF_VAR_default_ssh_key_name=${TF_VAR_default_ssh_key_name}" \
           -e "TF_VAR_default_ssh_public_key=${TF_VAR_default_ssh_public_key}" \
           -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
           -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
           -e "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}" \
           hashicorp/terraform init
```

#### Initialize terraform if it isn't initialized yet
After following the instructions in the README of the "terraform_backend" folder to bring up S3 and Dynamo, copy the "backend.conf" from "terraform_backend" to the current folder.

```
cp ../terraform_backend/backend.conf backend.conf
```

Then, initialize Terraform.

```
terraform init -backend-config=backend.conf
```

Obs: Sensitive variables (such as AWS_ACCESS_KEY_ID) are in environment variables, not hardcoded in the "backend.conf" file.

#### Create all instance related resources

```
terraform apply
```

#### SSH into the instance
The PRIVATE_KEY_FILE is the private key generated during the "Generate SSH key pair" step. The INSTANCE_PUBLIC_IP is the public IP of the instance, which Terraform printed to the screen as "instance_public_ip".

```
ssh -i PRIVATE_KEY_FILE ubuntu@INSTANCE_PUBLIC_IP

# e.g
ssh -i ~/.ssh/id_rsa ubuntu@216.239.32.10
```

#### Destroy the instance and everything created with it (optional)

```
terraform destroy
```
