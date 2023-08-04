# Wireguard Configuration on Ubuntu 22.04
These instructions are based on the following guide: <https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-ubuntu-22-04>.

## Install Ansible
Requires the "ansible" package. Just the "ansible-core" one is not enough, as "ansible-core" lacks the [community.general.timezone](https://docs.ansible.com/ansible/latest/collections/community/general/timezone_module.html) module. More info at the [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/).

To check whether "community.general.timezone" is installed, run the following command:

```
ansible-galaxy collection list | grep community.general
```

To install it, use:

```
ansible-galaxy collection install community.general
```


## Server Setup With Ansible
The "configure_server.yml" playbook installs Wireguard, generates a key pair and a configuration file for the VPN server, starts Wireguard, and configures Wireguard to restart on boot. 

#### Run the "configure_server.yml" playbook

Edit the file named "inventory.ini" with the following content. Substitute "15.228.237.103" with the EC2 instance public IP address. The "terraform apply" command should have printed the public IP to the terminal if the instructions in the ["../infrastructure" README](/infrastructure/README.md) worked well.

```
vim inventory.ini
```

Substitute "/path/to/private/ssh/key" with a private SSH key that can access the EC2 instance. Like the one generated following the [instructions in the "../infrastructure" README](/infrastructure/README.md).

```
[vpnserver]
15.228.237.103 ansible_ssh_private_key_file=/path/to/private/ssh/key address=10.8.0.1/24 listen_port=51820

[vpnclients]
# (...)
```

Run the "configure_server.yml" playbook.

```
ansible-playbook -i inventory.ini configure_server.yml
```

If there's more than one VPN server to be configured, it's probably desirable to use an unique "address" variable for each VPN server. Maybe even a different "listen_port". Observe that, to use a different "listen_port", the previously ran Terraform code must also be changed. At the moment, the Terraform code only supports creating one VPN server at a time, and it doesn't support replicas at all.

```
[vpnserver]
15.228.237.103 ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/private/ssh/key address=10.8.0.1/24 listen_port=51820
123.234.153.11 ansible_user=ubuntu ansible_ssh_private_key_file=/path/to/private/ssh/key address=10.9.0.1/24 listen_port=51821

[vpnclients]
# (...)
```

Warning: the default "ubuntu" user is used in the example. In a production environment, it's more suitable to create a specific user for this task (even though that user needs access to sudo).

## Setup Ubuntu client With Ansible
The "configure_client.yml" playbook installs Wireguard, generates a key pair and a configuration file for the VPN client(s), starts Wireguard, and configures Wireguard to restart on boot. 

#### Run the "configure_client.yml" playbook

Edit the file named "inventory.ini" with the following content. Substitute "11.222.333.44" with a client IP address that is accessible. 

```
vim inventory.ini
```

Substitute "/path/to/private/ssh/key" with a private SSH key that can access the client. Substitute "USER_IN_CLIENT_MACHINE" with the user on the client machine. Substitute PEER_PRIVATE_VPN_IP with an unique IP in the range "10.8.0.0/24", but don't use "10.8.0.0/24" (it means all IPs in that range) or "10.8.0.1/24" (already assigned to the VPN server).

```
[vpnserver]
# (...)

[vpnclients]
11.222.333.44 ansible_user=USER_IN_CLIENT_MACHINE ansible_ssh_private_key_file=/path/to/private/ssh/key peer_vpn_ip=PEER_PRIVATE_VPN_IP
```

If there's more than one client, just append the other clients IPs to the "vpnclients" section in the "inventory.ini" file. For example:

```
[vpnserver]
# (...)

[vpnclients]
11.222.333.44 ansible_user=USER_IN_CLIENT_MACHINE ansible_ssh_private_key_file=/path/to/private/ssh/key peer_vpn_ip=PEER_PRIVATE_VPN_IP
222.333.44.55 ansible_user=USER_IN_CLIENT_MACHINE1 ansible_ssh_private_key_file=/path/to/private/ssh/key1 peer_vpn_ip=PEER_PRIVATE_VPN_IP1
```

Run the "configure_client.yml" playbook.

```
ansible-playbook -i inventory.ini configure_client.yml
```

## "Mesh Network"
It's necessary to configure which peer can access which peer (like peer-to-peer networks and mesh networks). A peer can be a server or a client. The "trust_a_server.yml" playbook can be used to add a server public key to the configuration file of a client. The "trust_a_client.yml" playbook can be used to add a client public key to the configuration file of a server or to the configuration file of another client.

### Make a client trust a server

#### Run the "trust_a_server.yml" playbook

Make all clients previously specified in the "inventory.ini" file trust the server.

```
ansible-playbook -i inventory.ini trust_a_server.yml
```

Substitute SERVER_PUBLIC_IP with the EC2 instance public IP. It's probably the same IP address that's in "inventory.ini". Substitute SERVER_PUBLIC_KEY with the server Wireguard public key (located in the server at the path "/etc/wireguard/public.key").

```
ansible-playbook -i inventory.ini trust_a_server.yml --extra-vars "server_public_ip='SERVER_PUBLIC_IP' trusted_server_public_key='SERVER_PUBLIC_KEY'"
```

Make just one client trust the server.

```
TODO
```

### Make a client/server trust another client
Client A already trusts client B if the connection is made via the server they're both connected to. But, this may be useful to connect them directly.

#### Run the "trust_a_client.yml" playbook

Make ALL clients/servers (specified in "inventory.ini" file) trust a client B. Substitute CLIENT_B_HOSTNAME with the client B hostname previously specified in the "inventory.ini". Substitute CLIENT_PRIVATE_VPN_IP with the IP of the client in the VPN (like 10.8.0.2). Substitute CLIENT_B_PUBLIC_KEY with its Wireguard public key (located in client B at the path "/etc/wireguard/public.key").

```
ansible-playbook -i inventory.ini trust_a_client.yml --extra-vars "trusted_client_hostname='CLIENT_B_HOSTNAME' trusted_client_private_vpn_ip='CLIENT_PRIVATE_VPN_IP' trusted_client_public_key='CLIENT_B_PUBLIC_KEY'"
```

Make just a client A trust a client B.

```
TODO
```

## Manual Server/Client Setup

#### Install Wireguard
Check <https://www.wireguard.com/install/> for more install options (including Android, iOS, Windows, and macOS).

```
sudo apt update
sudo apt install -y wireguard
```

#### Generate key pair

```
wg genkey | sudo tee /etc/wireguard/private.key
sudo chmod go= /etc/wireguard/private.key
sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
```

#### Server configuration file

```
echo "\
[Interface]
PrivateKey = $(sudo cat /etc/wireguard/private.key)
Address = 10.8.0.1/24
ListenPort = 51820
SaveConfig = true
" | sudo tee /etc/wireguard/wg0.conf
```

#### Client configuration file

Substitute "base64_encoded_server_public_key_goes_here" and "server_public_ip_goes_here" with appropriate values.

```
echo "\
[Interface]
PrivateKey = $(sudo cat /etc/wireguard/private.key)
# Incrementing addresses by 1 each time you add a peer is generally the easiest way to allocate IPs.
Address = 10.8.0.2/24

[Peer]
PublicKey = base64_encoded_server_public_key_goes_here
# Allow all VPN IPs.
AllowedIPs = 10.8.0.0/24
Endpoint = server_public_ip_goes_here:51820
PersistentKeepalive=16" | sudo tee /etc/wireguard/wg0.conf
```

#### How to configure a peer A to trust a peer B
Both clients and servers are treated as peers. The client(s) already trust the server. Now, it's necessary to configure the server to trust each client. If there's multiple clients, they don't trust each other *directly* yet. It's possible to configure a client to trust another client. That's how it's done:

Peer B side: find a way to share peer's B public key with peer A. The simplest way is to just copy and paste the key.
```
# After executing the following command, copy the public key.
sudo cat /etc/wireguard/public.key
```

Peer A side: if peer A wg0 interface isn't up yet, it's necessary to up it. Then, run the following command to trust in peer B public key.
```
# Substitute "base64_encoded_peer_public_key_goes_here" with the copied key.
# "10.8.0.2" should be the same IP address used in the "Client configuration file" step. It's also the IP that will appear on peer B wg0 interface.

sudo wg set wg0 peer base64_encoded_peer_public_key_goes_here allowed-ips 10.8.0.2
```

Peer A side: restart wg0 interface.

```
# If using wg-quick, run
sudo wg-quick down wg0; sudo wg-quick up wg0

# If using systemctl, run
sudo systemctl restart wg-quick@wg0.service
```


#### Client/Server VPN startup

Automatically on boot with systemctl.

```
# Start the VPN.
sudo systemctl enable wg-quick@wg0.service
sudo systemctl start wg-quick@wg0.service

# Stop the VPN.
sudo systemctl stop wg-quick@wg0.service
sudo systemctl disable wg-quick@wg0.service
```

Manually only with wg-quick.

```
# Start the VPN.
sudo wg-quick up wg0

# Stop the VPN.
sudo wg-quick down wg0
```
