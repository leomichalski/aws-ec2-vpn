# Infrastructure User
Creates an AWS user (and a group) for running the [infrastructure Terraform code](/infrastructure), which creates an EC2 instance for hosting the VPN server.

WARNING: not suitable for use in an automated pipeline.

## Instructions

#### Install Terraform
Terraform is required to run the following instructions. It can be [installed](https://developer.hashicorp.com/terraform/downloads), or used from [Docker](https://hub.docker.com/r/hashicorp/terraform/).

#### Define the necessary AWS keys as environment variables

```
# Always required:
export AWS_ACCESS_KEY_ID="AFG..."
export AWS_SECRET_ACCESS_KEY="ASR..."

# May be necessary:
export AWS_SESSION_TOKEN="WIo..."
```

#### Initialize terraform locally if it isn't initialized yet

```
terraform init
```

#### Create the user and its policies

```
terraform apply
```

#### Get the user access keys
After running "terraform apply", the access keys (access key id and secret acess key) will be printed to the screen in clear text. The keys will also be stored in the local Terraform state files (it's recommended to delete these files to avoid unintended access). Use them to follow the [README](/infrastructure/README.md) in the [infrastructure](/infrastructure) folder, not the one in the [terraform_backend](/terraform_backend) folder.

#### Destroy the backend resources (optional)

```
terraform destroy
```
