#!/bin/sh

red="\e[31m"
green="\e[32m"
blue="\e[34m"
cyan="\e[36m"
clear="\e[0m"

dir_home=$HOME
dir_rke2="/etc/rancher/rke2"
file_rke2_config="config.yaml"
usr_id=$(id -u)

#Prompt for required information
read -p "Enter the TLS-SAN to connect to RKE2 (i.e., https://rancher.domain.com:9345): " rke2_domain
read -p "Enter the token to use: " rke2_token

#Create the required directories and files
echo "${blue}[+] Creating required directories and files${clear}"
sudo mkdir -p /etc/rancher/rke2/
sudo touch /etc/rancher/rke2/config.yaml

#Populate the config.yaml file
echo "${blue}[+] Populating the${clear} ${cyan}/etc/rancher/rke2/config.yaml${clear} ${blue}file${clear}"
echo "token: $rke2_token" | sudo tee --append $dir_rke2/$file_rke2_config
echo "server: $rke2_domain" | sudo tee --append $dir_rke2/$file_rke2_config

#Install required packages
sudo apt update
sudo apt install -y curl iptables

#Install Rancher RKE2 Agent
echo "${blue}[+] Installing RKE2 Agent${clear}"
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sudo sh -
sudo systemctl enable rke2-agent.service
sudo systemctl start rke2-agent.service

echo "${green}RKE Agent installation completed.${clear}"

#Required directories and configuration files for this script:
#sudo mkdir -p /etc/rancher/rke2/
#sudo nano /etc/rancher/rke2/config.yaml
#config.yaml contents:
#server: https://<IP or FQDN>:9345
#token: <secret>

#Documentation: https://ranchermanager.docs.rancher.com/how-to-guides/new-user-guides/kubernetes-cluster-setup/rke2-for-rancher, https://docs.rke2.io/