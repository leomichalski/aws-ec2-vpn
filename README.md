# AWS-EC2-VPN
Infrastructure as code (IaC) of a VPN server meant for accessing machines behind NAT firewalls commonly used by ISPs.

- [Folder Structure](#folder-structure)
- [Instructions](#instructions)

## Folder Structure

* **[infrastructure](/infrastructure/)**: infrastructure as code to configure an EC2 instance including VPC, EBS, etc.
* **[infrastructure_user](/infrastructure_user/)**: user meant for running the code in the "infrastructure" folder.
* **[installation](/installation/)**: useful to configure the VPN server and its clients.
* **[terraform_backend](/terraform_backend/)**: It setups a remote backend for storing files related to the Terraform state of the code in the "infrastructure" folder.

## Instructions

#### Provision the Terraform backend

Following the "terraform_backend" folder ["README.md"](/terraform_backend/README.md), setup a remote backend for running the Terraform code in the "infrastructure" folder. If one wants to skip this step and use a local backend, just remove or comment the following line from the ["infrastructure/main.tf"](/infrastructure/main.tf) file:

```
  backend "s3" {}
```

#### Create an IAM user for renting AWS resources

Following the "infrastructure_user" folder ["README.md"](/infrastructure_user/README.md), create an IAM user for running the code in the "infrastructure" folder. It may be okay to run that code with another user credentials (such as root or admin), but it's recommended to use the "infrastructure_user" if setting up a pipeline with Jenkins.

#### Rent the VPN infrastructure with Terraform, then configure the VPN server with Ansible

Follow the instructions in the "infrastructure" folder ["README.md"](/infrastructure/README.md) file to bring up an EC2 instance and other AWS resources necessary to properly host the VPN server.

Follow the instructions in the "installation" folder ["README.md"](/installation/README.md) to setup the VPN server and its clients. There's two setup options: Ansible or manual. The "installation" instructions work with other Cloud Providers, the supported server operating system is Ubuntu 22.04.

#### [optional] Automate the VPN server renting with [Jenkins](https://www.jenkins.io/)

Jenkins server setup:
* If there's already a Jenkins server, install [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) there. Then, reuse the Jenkinsfile in the root folder of this directory to create a Jenkins pipeline.
* Otherwise, it's possible to temporarily setup Jenkins locally with the followings commands:

```
# Run Jenkins

docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home --name jenkins-server --privileged jenkins/jenkins:lts-jdk11

# Install Terraform in the Jenkins container
docker exec -it --user root jenkins-server bash

apt update && apt install -y wget lsb-release

wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

apt update && apt install -y terraform

exit

# Run the following command, then wait for the "initialAdminPassword" to appear on the screen. Then copy it.

docker logs -f jenkins-server

# Access http://localhost:8080 to manually setup the pipeline using the Jenkinsfile in the root folder of this directory. Use the "initialAdminPassword" to log in.
```

Generate SSH keys.

```
ssh-keygen -t rsa -b 4096
```

Create Jenkins credentials that the Jenkinsfile uses:

| ID                        | Content                                                                                                                   | Kind        |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------|-------------|
| AWS_ACCESS_KEY_ID         | Previously generated IAM user AWS access key id.                                                                          | Secret text |
| AWS_SECRET_ACCESS_KEY     | Previously generated IAM user AWS secret access key.                                                                      | Secret text |
| REGION                    | Chosen region (e.g "sa-east-1").                                                                                          | Secret text |
| AVAILABILITY_ZONE         | The availability zone must be in the chosen region (e.g. "sa-east-1a").                                                    | Secret text |
| S3_BACKEND_DYNAMODB_TABLE | Dynamo DB table name (e.g "my-terraform-state-lock").                                                                     | Secret text |
| S3_BACKEND_BUCKET         | S3 bucket name (e.g "my-terraform-state").                                                                                | Secret text |
| S3_BACKEND_KEY_PATH       | Path to the Terraform state file (e.g. "path/to/terraform.tfstate") in the S3 bucket.                                      | Secret text |
| ENCRYPT                   | It enables server side encryption of the Terraform state file. Set the value to "true" (case sensitive).                  | Secret text |
| SSH_PUBLIC_KEY            | Previously generated SSH public key (the ".pub" file). Terraform copies it to the VPN server.                             | Secret text |
| SSH_KEY_NAME              | The key name of the previously generated SSH keys (same as the private key filename, not the whole path).                 | Secret text |
