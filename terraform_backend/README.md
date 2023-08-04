# Terraform Backend
A backend defines where Terraform stores its state data files. This folder is used to setup a remote backend for the [infrastructure Terraform code](/infrastructure) of the EC2 instance. The state files are stored in a S3 bucket, and the lock synchronization is implemented with a Dynamo DB table.

- [Instructions](#instructions)
    - [Install Terraform](#install-terraform)
    - [Initialize terraform locally if it isn't initialized yet](#initialize-terraform-locally-if-it-isnt-initialized-yet)
    - [Create the backend resources (S3 bucket, etc)](#create-the-backend-resources-s3-bucket-etc)
    - [Destroy the backend resources (optional)](#destroy-the-backend-resources-optional)


## Instructions

#### Install Terraform
Terraform is required to run the following instructions. It can be [installed](https://developer.hashicorp.com/terraform/downloads), or used from [Docker](https://hub.docker.com/r/hashicorp/terraform/).

#### Initialize terraform locally if it isn't initialized yet

```
terraform init
```

#### Create the backend resources (S3 bucket, etc)

```
terraform apply
```

#### Destroy the backend resources (optional)

```
terraform destroy
```
