#!/bin/bash
yum -y update
amazon-linux-extras install epel -y
yum -y install nginx git ruby
cd /home/ec2-user
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto
service codedeploy-agent start
service codedeploy-agent enable
systemctl start nginx
systemctl enable nginx
cd /usr/share/nginx/html
yum update -y
curl --silent --location https://rpm.nodesource.com/setup_12.x |  bash -
yum install -y nodejs-12.18.4-1nodesource
npm install -g @vue/cli@latest