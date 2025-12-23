#!/bin/bash

echo "Updating system repos...!"
sudo apt update && sudo apt upgrade -y

if ! command -v docker &> /dev/null
then
    echo "Docker not found. Installing...!"
    sudo apt install docker.io docker-compose -y
    sudo systemctl enable --now docker
else
    echo "Docker is already installed...!"
fi

echo "Creating volumes...!"
mkdir -p ./etc-pihole
mkdir -p ./etc-dnsmasq.d

if [ -f "docker-compose.yml" ]; then
    echo "Starting Pi-hole..."
    sudo docker-compose up -d
    echo "Installation Complete! Login at http://$(hostname -I | awk '{print $1}')/admin"
else
    echo "Error: docker-compose.yml not found!"
    exit 1
fi

