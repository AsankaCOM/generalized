#!/bin/bash
sudo yum install lftp -y
sudo adduser onetick
sudo mkdir /data
sudo chown -R onetick:onetick /data
sudo mkdir /home/onetick/build /home/onetick/client_data /home/onetick/licence /home/onetick/memdb /home/onetick/security /home/onetick/om /home/onetick/rawdata /home/onetick/refdata /home/onetick/security /home/onetick/symbol /home/onetick/log
sudo mkdir /home/onetick/client_data/config /home/onetick/client_data/crontab /home/onetick/client_data/csv /home/onetick/client_data/otqs /home/onetick/client_data/scripts /home/onetick/client_data/udep
sudo mkdir /home/onetick/log/app /home/onetick/log/ft /home/onetick/log/ftstate /home/onetick/log/lftp /home/onetick/log/license_server /home/onetick/log/monitor /home/onetick/log/onetick_daemon /home/onetick/log/otq_query_loader_daily
sudo chown -R onetick:onetick /home/onetick
sudo su -l onetick -c "wget -r 'ftp://omddist:$ftp_password@ftp.onetick.com/dist/one_market_data_server_64_gcc4.8_Linux_x86_64.tar.gz'"
sudo su -l onetick -c "tar xvf ftp.onetick.com/dist/one_market_data_server_64_gcc4.8_Linux_x86_64.tar.gz"
sudo su -l onetick -c "one_market_data/one_tick/bin/get_host_info.exe"