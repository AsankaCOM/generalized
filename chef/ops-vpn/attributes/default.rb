# openssl passwd -1 'mypasswod here'
default['openvpn']['password'] = ''
default['vpn']['slack']['url'] = ''
# Change bucket names
default['vpn']['backup'] = 'bucket-backups/openvpn'
default['vpn']['log'] = 'bucket-logs/openvpn/log'
