username = node['vpn']['mfa']

bash 'Unlock Google auth' do
  code %W(
    /usr/local/openvpn_as/scripts/sacli --user #{username} --lock 0
    GoogleAuthLock
  ).join(' ')
end
