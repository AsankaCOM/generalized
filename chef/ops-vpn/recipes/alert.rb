template '/usr/local/bin/vpn_alert' do
  source 'vpn_alert.erb'
  mode '755'
end

cron 'alert dns fail login' do
  minute '*/2'
  command %W{
    /usr/local/bin/vpn_alert
  }.join(" ")
end
