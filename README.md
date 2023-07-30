# aws-ec2-vpn

## Instructions

#### Install Terraform
Terraform is required to run the following instructions. It can be [installed](https://developer.hashicorp.com/terraform/downloads), or used from Docker.

```
docker pull hashicorp/terraform
```

#### Generate SSH key pair
The following command will generate two files. The .pub file content should be passed as the input variable "default_ssh_public_key" to the "create_instance.tf" script, which will copy the public key to the EC2 instance. The other file should be used to SSH into the instance.

```
ssh-keygen -t rsa -b 4096
```

#### Create the instance
Fill the empty variables. Substitute "/path/to/file.pub" with the appropriate path.

```
# SSH key
TF_VAR_default_ssh_key_name=""
TF_VAR_default_ssh_public_key=$(cat /path/to/file.pub)

# AWS IAM temporary access
TF_VAR_aws_access_key=""
TF_VAR_aws_secret_key=""
TF_VAR_aws_session_token=""
```

```
# using installed Terraform
terraform plan
terraform apply

# or, using Docker
docker run --rm \
           -v ${PWD}:/current_dir -w /current_dir \
           --user "$(id -u):$(id -g)" \
           -e "TF_VAR_aws_access_key=${TF_VAR_aws_access_key}" \
           -e "TF_VAR_aws_secret_key=${TF_VAR_aws_secret_key}" \
           -e "TF_VAR_aws_session_token=${TF_VAR_aws_session_token}" \
           -e "TF_VAR_default_ssh_key_name=${TF_VAR_default_ssh_key_name}" \
           -e "TF_VAR_default_ssh_public_key=${TF_VAR_default_ssh_public_key}" \
           hashicorp/terraform plan

docker run --rm \
           -v ${PWD}:/current_dir -w /current_dir \
           --user "$(id -u):$(id -g)" \
           -e "TF_VAR_aws_access_key=${TF_VAR_aws_access_key}" \
           -e "TF_VAR_aws_secret_key=${TF_VAR_aws_secret_key}" \
           -e "TF_VAR_aws_session_token=${TF_VAR_aws_session_token}" \
           -e "TF_VAR_default_ssh_key_name=${TF_VAR_default_ssh_key_name}" \
           -e "TF_VAR_default_ssh_public_key=${TF_VAR_default_ssh_public_key}" \
           hashicorp/terraform apply -auto-approve
```

#### SSH into the instance
The PRIVATE_KEY_FILE is the private key generated during the "Generate SSH key pair" step. The INSTANCE_PUBLIC_IP is the public ip of the instance, which Terraform printed to the screen as "instance_public_ip".

```
ssh -i PRIVATE_KEY_FILE ubuntu@INSTANCE_PUBLIC_IP

# e.g
ssh -i /home/ubuntu/.ssh/id_rsa ubuntu@216.239.32.10
```

#### Destroy the instance and everything created with it

```
terraform destroy

# or, using Docker
docker run --rm \
           -v ${PWD}:/current_dir -w /current_dir \
           --user "$(id -u):$(id -g)" \
           -e "TF_VAR_aws_access_key=${TF_VAR_aws_access_key}" \
           -e "TF_VAR_aws_secret_key=${TF_VAR_aws_secret_key}" \
           -e "TF_VAR_aws_session_token=${TF_VAR_aws_session_token}" \
           -e "TF_VAR_default_ssh_key_name=${TF_VAR_default_ssh_key_name}" \
           -e "TF_VAR_default_ssh_public_key=${TF_VAR_default_ssh_public_key}" \
           hashicorp/terraform destroy -auto-approve
```
