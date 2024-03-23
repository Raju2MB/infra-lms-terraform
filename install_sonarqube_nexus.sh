#!/bin/bash
#install docker
sudo apt-get update
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu  
newgrp docker
sudo chmod 777 /var/run/docker.sock

# create sonarqube
docker container run -dt --name sonarqube -p 9000:9000 sonarqube:latest