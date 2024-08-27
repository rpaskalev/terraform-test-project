#!/bin/bash
echo "Starting app2"
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<html><body><h1>Welcome to app2 page</h1></body></html>" > /var/www/html/index.html
