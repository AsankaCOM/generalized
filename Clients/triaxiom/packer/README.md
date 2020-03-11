
# Guide to install packer and create AMIs

This *REAMDE.md* file explains step by step how to install packer and create the **application** and the **one-tick** AMIs from it.

First is necessary to install packer:

```bash
sudo yum update -y
sudo wget https://releases.hashicorp.com/packer/1.4.5/packer_1.4.5_linux_amd64.zip
sudo unzip packer_1.4.5_linux_amd64.zip
```

Next, move the packer tool to the */bin* directory:

```bash
sudo mv packer /bin
```

Then, locate the *.json* files (one is the application and the other is the one-tick) and validate with the following command:

```bash
packer validate ./packer/application/packer-template.json
```
```bash
packer validate ./packer/one-tick/packer-template.json
```

This is just to verify if the template is valid. If the validation is successfull, have to move to the following command to create the AMIs:

```bash
packer build \
    -var 'aws_access_key=YOUR ACCESS KEY' \
    -var 'aws_secret_key=YOUR SECRET KEY' \
    -var 'aws_access_token=YOUR ACCESS TOKEN' \
    ./packer/application/packer-template.json
```
```bash
packer build \
    -var 'aws_access_key=YOUR ACCESS KEY' \
    -var 'aws_secret_key=YOUR SECRET KEY' \
    -var 'aws_access_token=YOUR ACCESS TOKEN' \
    ./packer/one-tick/packer-template.json
```
