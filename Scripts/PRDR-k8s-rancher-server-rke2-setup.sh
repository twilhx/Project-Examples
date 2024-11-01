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
echo "${cyan}Enter the domain to use for Rancher Server (i.e., rancher.domain.com):${clear}"
read domain

echo "${cyan}Enter the token to use:${clear}"
read rke2t

echo "${cyan}Enter the TLS-SAN to use:${clear}"
read rke2ts

#Force the values to be a string
rke2_domain="$domain"
rke2_token="$rke2t"
rke2_tls_san="$rke2ts"

#Create the required directories and files
echo "${blue}[+] Creating required directories and files${clear}"
sudo mkdir -p /etc/rancher/rke2/
sudo touch /etc/rancher/rke2/config.yaml

#Populate the config.yaml file
echo "${blue}[+] Populating the${clear} ${cyan}/etc/rancher/rke2/config.yaml${clear} ${blue}file${clear}"
echo "token: $rke2_token" | sudo tee --append $dir_rke2/$file_rke2_config
echo "tls-san:" | sudo tee --append $dir_rke2/$file_rke2_config
echo "  - $rke2_tls_san" | sudo tee --append $dir_rke2/$file_rke2_config

#Install required packages
echo "${blue}[+] Installing Required Packages${clear}"
sudo apt update
sudo apt install -y curl git iptables

#Install Helm and adding required repos
echo "${blue}[+] Installing Helm${clear}"
curl -sfL  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add jetstack https://charts.jetstack.io
helm repo update

#Install Rancher RKE2 Server
echo "${blue}[+] Installing RKE2 Server${clear}"
curl -sfL https://get.rke2.io | sudo sh -
sudo systemctl enable rke2-server.service
sudo systemctl start rke2-server.service

#Copy the binaries to /usr/local/bin
echo "${blue}[+] Copying Binaries${clear}"
sudo cp /var/lib/rancher/rke2/bin/* /usr/local/bin/

#Allow the local user to manage the Kubernetes cluster
echo "${blue}[+] Copying the /etc/rancher/rke2/rke2.yaml to ~/.kube/config${clear}"
mkdir $dir_home/.kube
sudo cp /etc/rancher/rke2/rke2.yaml $dir_home/.kube/config
sudo chown $usr_id $dir_home/.kube/config

#Install Rancher Server
echo "${blue}Waiting for 3 minutes for all RKE2 pods to start${clear}"
sleep 3m #Wait for 3 minutes for all RKE2 pods to start
echo "${blue}[+] Installing Rancher Server. This process will take a while${clear}"
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true
kubectl create namespace cattle-system
helm install rancher rancher-stable/rancher --namespace cattle-system --set hostname=$rke2_domain --set bootstrapPassword=admin

echo "${green}RKE2 and Rancher Server installation completed. Binaries can be found at${clear} ${blue}/var/lib/rancher/rke2/bin/${clear}."

#Create the required directories and configuration files before running this script:
#sudo mkdir -p /etc/rancher/rke2/
#sudo nano /etc/rancher/rke2/config.yaml
#config.yaml contents:
#token: <secret>
#tls-san:
#   - <IP or FQDN>

#Web UI can be accessed at https://<FQDN>/ after Rancher Server installation