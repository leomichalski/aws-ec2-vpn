# Wireguard Configuration on Ubuntu 22.04
These instructions are based on the following guide: <https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-ubuntu-22-04>.

## Server Setup With Ansible
The Ansible playbook installs Wireguard, generates a key pair and a configuration file for the VPN server, starts Wireguard, and configures Wireguard to restart on boot. After all that, it's still necessary to follow the manual instructions below to setup Wireguard on client machines. It's also necessary to copy each client machine public key to the server.

#### Install Ansible
Requires the "ansible" package. Just the "ansible-core" one is not enough, as "ansible-core" lacks the [community.general.timezone](https://docs.ansible.com/ansible/latest/collections/community/general/timezone_module.html) module. More info at the [Ansible Installation Guide](https://docs.ansible.com/ansible/latest/installation_guide/).

To check whether "community.general.timezone" is installed, run the following command:

```
ansible-galaxy collection list | grep community.general
```

To install it, use:

```
ansible-galaxy collection install community.general
```


#### Run the Ansible playbook

Create a file with the name "inventory.ini" with the following content. Substitute "15.228.237.103" with the EC2 instance public IP address. The "terraform apply" command should have printed the public IP to the terminal if the instructions in the ["../infrastructure" README](/infrastructure/README.md) worked well.

```
[vpnservers]
15.228.237.103
```

e.g
```
echo "\
[vpnservers]
15.228.237.103
" | tee inventory.ini
```

If there's more than one instance, just append the other instances public IPs to the "inventory.ini" file. For example:

```
[vpnservers]
15.228.237.103
15.229.16.254
54.232.24.149
```

Substitute "/path/to/private/ssh/key" with a private SSH key that can access the EC2 instance. Like the one generated following the [instructions in the "../infrastructure" README](/infrastructure/README.md).

```
ansible-playbook --private-key /path/to/private/ssh/key -i inventory.ini playbook.yml
```

## Server/Client Setup Without Ansible

#### Install Wireguard
Check <https://www.wireguard.com/install/> for more install options (including mobile apps).

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
PersistentKeepalive=16

" | sudo tee /etc/wireguard/wg0.conf
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
