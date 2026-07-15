#!/bin/bash

# Install JRE
sudo apt install openjdk-17-jre-headless -y

# Create keyrings folder
sudo mkdir -p /usr/share/keyrings

# Download Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2023.key

# Add Jenkins repo
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update
sudo apt-get update -y

# Install Jenkins
sudo apt-get install jenkins -y
