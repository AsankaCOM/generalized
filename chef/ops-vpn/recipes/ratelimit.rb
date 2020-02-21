bash "Increase rate limit a bit" do
  code %W{
  /usr/local/openvpn_as/scripts/sacli -k vpn.server.lockout_policy.n_fails -v 6 ConfigPut
  /usr/local/openvpn_as/scripts/sacli start
  }.join(" ")
end
