#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo mkdir /var/www/html/app1
sudo echo "</h1> APP1 web page at $(hostname -f) </h1>" > /var/www/html/app1/index.html