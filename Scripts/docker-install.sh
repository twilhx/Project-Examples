#!/bin/sh
#A simple script to automate Docker installs.
#Currently only supports Debian and Ubuntu. The current version does not include downstream derivatives such as Kali Linux or Linux Mint.
#To use this script, run the following command: curl -s https://raw.githubusercontent.com/twilhx/Project-Examples/refs/heads/main/Scripts/docker-install.sh | sh 

red="\e[31m"
green="\e[32m"
blue="\e[34m"
clear="\e[0m"
oscheck=$(cat /etc/os-release | grep -w "ID=*")
osname="${oscheck#ID=}"

debian_install(){
    echo "${blue}[+] Debian distribution detected. Installing Docker for Debian..."

    #Install necessary dependencies
    echo "${blue}[+] Installing necessary dependencies${clear}"
    sudo apt update
    sudo apt install -y ca-certificates curl
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

    echo "${green}[+] Docker installation completed.${clear}"
}

ubuntu_install(){
    echo "${blue}[+] Ubuntu distribution detected. Installing Docker for Ubuntu..."

    #Install necessary dependencies
    echo "${blue}[+] Installing necessary dependencies${clear}"
    sudo apt update
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    #Add the Docker repositories to Apt sources
    echo "${blue}[+] Adding the Docker repository to Apt sources${clear}"
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    #Install packages
    echo "${blue}[+] Installing Docker packages${clear}"
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo "${green}[+] Docker installation completed.${clear}"
}

if [ "$osname" = "debian" ] 2>/dev/null
then
    debian_install
elif [ "$osname" = "ubuntu" ] 2>/dev/null
then
    ubuntu_install
else
    echo "${red}[WARNING] This script does not support your distribution. To prevent potential errors, please install Docker manually."
fi