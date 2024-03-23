#!/bin/bash
#install docker
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu  
newgrp docker
sudo chmod 777 /var/run/docker.sock
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

# install nexus
sudo apt update -y
docker run -d -p 8081:8081 --name nexus sonatype/nexus3

