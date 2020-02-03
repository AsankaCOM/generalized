# Backup user and dump log

template '/usr/local/bin/vpn_backup_user' do
  source 'vpn_backup_user.erb'
  mode '755'
end

template '/usr/local/bin/vpn_dump_log' do
  source 'vpn_dump_log.erb'
  mode '755'
end

cron 'Dump Daily Log' do
  minute '50'
  hour '6'
  command %W{
    /usr/local/bin/vpn_dump_log
  }.join(" ")
end

cron 'Backup VPN config and user' do
  minute '0'
  hour '7'
  command %W{
    /usr/local/bin/vpn_backup_user
  }.join(" ")
end
