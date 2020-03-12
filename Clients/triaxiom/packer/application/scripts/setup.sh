#!/bin/bash
sudo adduser onetick
sudo su -l onetick -c "curl -O https://repo.continuum.io/archive/Anaconda3-2019.10-Linux-x86_64.sh"
sudo su -l onetick -c "bash Anaconda3-2019.10-Linux-x86_64.sh -b -p /home/onetick/anaconda3"
sudo su -l onetick -c "/home/onetick/anaconda3/bin/pip install tzlocal"
sudo su -l onetick -c "echo \"export PATH=\"/home/onetick/anaconda3/bin:$PATH\"\" >> /home/onetick/.bashrc"
sudo su -l onetick -c "(crontab -l 2>/dev/null; echo \"SHELL=/bin/bash\") | crontab -"
sudo su -l onetick -c "(crontab -l 2>/dev/null; echo \"PATH=/home/onetick/anaconda3/bin:/home/onetick/anaconda3/lib:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
\") | crontab -"
sudo su -l onetick -c "(crontab -l 2>/dev/null; echo \"USER=onetick\") | crontab -"
sudo su -l onetick -c "(crontab -l 2>/dev/null; echo \"@reboot     python /home/onetick/client_data/scripts/py/onetick_library.py --start_on_reboot\") | crontab -"
sudo su -l onetick -c "(crontab -l 2>/dev/null; echo \"55  7 * * * python /home/onetick/client_data/scripts/py/onetick_library.py --run_license_getter\") | crontab -"
sudo su -l onetick -c "(crontab -l 2>/dev/null; echo \" 0 14 * * * python /home/onetick/client_data/scripts/py/onetick_library.py --run_batch_jobs\") | crontab -"
sudo su -l onetick -c "(crontab -l 2>/dev/null; echo \" 0  2 * * * python /home/onetick/client_data/scripts/py/onetick_library.py --run_batch_jobs\") | crontab -"