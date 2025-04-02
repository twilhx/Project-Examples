#!/bin/sh

green="\e[32m"
blue="\e[34m"
clear="\e[0m"

#Install necessary dependencies
echo "${blue}[+] Installing necessary dependencies${clear}"
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

#Add the Docker repositories to Apt sources
echo "${blue}[+] Adding the Docker repository to Apt sources${clear}"
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Install packages
echo "${blue}[+] Installing Docker packages${clear}"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "${green}[+] Docker Installation Complete. Run the following command to verify if Docker has installed successfully:${clear} ${blue}sudo docker run hello-world${clear}"

#Documentation: https://docs.docker.com/engine/install/debian/
#Verify if the installation is successful: sudo docker run hello-world
