#!/bin/bash
sudo yum update -y
sudo adduser onetick
sudo su -l onetick -c "curl -O https://repo.continuum.io/archive/Anaconda3-2019.10-Linux-x86_64.sh"
sudo su -l onetick -c "bash Anaconda3-2019.10-Linux-x86_64.sh -b -p /home/onetick/anaconda3"
sudo su -l onetick -c "/home/onetick/anaconda3/bin/pip install tzlocal"
sudo su -l onetick -c "echo \"export PATH=\"/home/onetick/anaconda3/bin:$PATH\"\" >> /home/onetick/.bashrc"
sudo yum install -y ruby wget
wget https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto