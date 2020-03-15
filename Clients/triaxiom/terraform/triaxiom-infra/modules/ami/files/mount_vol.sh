#!/bin/bash
while [ ! -e /dev/xvdf ] ; do sleep 1 ; done
sleep 5
sudo mkfs.ext4 /dev/xvdf
sudo mkdir -m 000 /data
sudo mount /dev/xvdf /data -t ext4
uuid_value=`sudo blkid -s UUID -o value /dev/xvdf`
fstab_line="UUID=${uuid_value}  /data  ext4  defaults,nofail  0  2"
echo ${fstab_line} | sudo tee -a /etc/fstab