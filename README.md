# AWS-EC2-VPN
Infrastructure as code (IaC) of a VPN server meant for accessing machines behind NAT firewalls commonly used by ISPs.

- [Folder Structure](#folder-structure)
- [Instructions](#instructions)

## Folder Structure

* **[infrastructure](/infrastructure/)**: infrastructure as code to configure an EC2 instance including VPC, EBS, etc.
* **[installation](/installation/)**: useful to configure the VPN server and its clients.
* **[terraform_backend](/terraform_backend/)**: It setups a remote backend for storing files related to the Terraform state of the code in the "infrastructure" folder.

## Instructions

Each folder described in the "Folder Structure" section contains a "README.md" file. It's necessary to follow them in correct order, which is: 

1. Following the "terraform_backend" folder ["README.md"](/terraform_backend/README.md), setup a remote backend for running the Terraform code in the "infrastructure" folder. If one wants to skip this step and use a local backend, just remove or comment the following line from the ["infrastructure/main.tf"](/infrastructure/main.tf) file:

```
  backend "s3" {}
```

2. Follow the instructions in the "infrastructure" folder ["README.md"](/infrastructure/README.md) file to bring up an EC2 instance and other AWS resources necessary to properly host the VPN server.

3. Follow the instructions in the "installation" folder ["README.md"](/installation/README.md) to setup the VPN server and its clients. There's two setup options: Ansible or manual. The "installation" instructions work with other Cloud Providers, the supported server operating system is Ubuntu 22.04.
