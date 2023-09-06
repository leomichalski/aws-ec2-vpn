# AWS-EC2-VPN
Infrastructure as code (IaC) of a VPN server meant for accessing machines behind NAT firewalls commonly used by ISPs.

- [Folder Structure](#folder-structure)
- [Instructions](#instructions)

## Folder Structure

* **[infrastructure](/infrastructure/)**: infrastructure as code to configure an EC2 instance including VPC, EBS, etc.
* **[infrastructure_user](/infrastructure_user/)**: user meant for running the code in the "infrastructure" folder.
* **[terraform_backend](/terraform_backend/)**: It setups a remote backend for storing files related to the Terraform state of the code in the "infrastructure" folder.
* **[installation](/installation/)**: useful to configure the VPN server and its clients.
* **[jenkins](/jenkins/)**: automates, with a continuous deployment pipeline, renting the infrastructure and installing the VPN.

## Instructions

#### Provision the Terraform backend

Following the "terraform_backend" folder ["README.md"](/terraform_backend/README.md), setup a remote backend for running the Terraform code in the "infrastructure" folder. If one wants to skip this step and use a local backend, just remove or comment the following line from the ["infrastructure/main.tf"](/infrastructure/main.tf) file:

```
  backend "s3" {}
```

#### Create an IAM user for renting AWS resources

Following the "infrastructure_user" folder ["README.md"](/infrastructure_user/README.md), create an IAM user for running the code in the "infrastructure" folder. It may be okay to run that code with another user credentials (such as root or admin), but it's recommended to use the "infrastructure_user" if setting up a pipeline with Jenkins.

#### Option 1: Run Terraform and Ansible commands manually to provision the VPN server

Follow the instructions in the "infrastructure" folder ["README.md"](/infrastructure/README.md) file to bring up an EC2 instance and other AWS resources necessary to properly host the VPN server.

Follow the instructions in the "installation" folder ["README.md"](/installation/README.md) to setup the VPN server.  The "installation" instructions work with other Cloud Providers, the supported server operating system is Ubuntu 22.04.

#### Option 2: Automate the VPN server provisioning with Jenkins

Follow the instructions in the "jenkins" folder ["README.md"](/jenkins/README.md) to setup a pipeline that provisions the VPN server.

#### With the VPN server configuration complete (manually or with a pipeline), setup the VPN clients

Follow the instructions in the "installation" folder ["README.md"](/installation/README.md) to setup the VPN clients. For Ubuntu based clients, there's two setup options: Ansible or manual. These options also work with some other Debian based distributions such as Raspberry Pi OS. For other clients (such as Android, iOS, macOS, Windows, etc.), check the [Wireguard VPN official install guide](https://www.wireguard.com/install/).
