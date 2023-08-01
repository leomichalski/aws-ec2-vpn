# AWS-EC2-VPN
Infrastructure as code of a VPN server meant for accessing machines behind a NAT firewall.

## Folder structure

* **infrastructure**: infrastructure as code (IaC) to configure an EC2 instance including VPC, EBS, etc.
* **installation**: should be run only after the instance is ready. It setups the Wireguard VPN server, and instructs on how to setup VPN clients.

## Instructions

The "Instructions" section in the [infrastructure folder README](/infrastructure/README.md) guides on how to provision the infrastructure necessary to install and run the Wireguard VPN. Both the "Server Setup With Ansible" or the "Server/Client Setup Without Ansible" sections in the [installation folder README](/installation/README.md) can be used to configure the VPN Server, but only the "Server/Client Setup Without Ansible" can be used to configure the clients.
