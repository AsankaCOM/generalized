# Disable root account

bash 'disable openvpn initial account' do
  code 'sed -i s/boot_pam_users\.0=openvpn/\#boot_pam_users\.0=openvpn/g /usr/local/openvpn_as/etc/as.conf; sudo service openvpnas restart'
  not_if "cat as.conf | grep '#boot_pam_users.0'"

end

service 'openvpnas' do
   action [:enable, :start]
end
