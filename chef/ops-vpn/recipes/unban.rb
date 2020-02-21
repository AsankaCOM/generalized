username = node['vpn']['unlock']

bash "Unlock banned user" do
  code %W{
    /usr/local/openvpn_as/scripts/sacli --user #{username} --key prop_deny --value false UserPropPut;
   /usr/local/openvpn_as/scripts/sacli start
  }.join(" ")
end
