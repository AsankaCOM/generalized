#
# Cookbook Name:: icinga2
# Recipe:: config
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

case node['platform']
when 'debian', 'ubuntu'
  package 'python-boto'
when 'redhat', 'centos', 'fedora'
  package 'python27-boto'
end
include_recipe "python"
python_pip "icinga-slack-webhook"
python_pip "nagios-plugin-elasticsearch"
python_pip "awscli"

python_pip 'boto' do
  version '2.39.0'
end

link "/usr/lib/nagios/plugins/check_elasticsearch" do
  to "/usr/local/bin/check_elasticsearch"
  not_if "test -L /usr/lib/nagios/plugins/check_elasticsearch"
end

template "#{node["icinga2"]["conf_dir"]}/icinga2_config.py" do
 source "icinga2_config.py.erb"
 owner node['icinga2']['user']
 group node['icinga2']['user']
 mode 0755
end

template "#{node["icinga2"]["conf_dir"]}/icinga2_opsworks.py" do
 source "icinga2_opsworks.py.erb"
 owner node['icinga2']['user']
 group node['icinga2']['user']
 mode 0755
end

template "#{node["icinga2"]["conf_dir"]}/services.conf" do
 source "services.conf.erb"
 owner node['icinga2']['user']
 group node['icinga2']['user']
 mode 0640
 notifies :restart, 'service[icinga2]'
end

template "#{node["icinga2"]["conf_dir"]}/chef-commands.conf" do
 source "chef-commands.conf.erb"
 owner node['icinga2']['user']
 group node['icinga2']['user']
 mode 0640
 notifies :restart, 'service[icinga2]'
end

#if node[:opsworks]
#  bash "Update icinga config" do
#   user "root"
#   cwd "#{node["icinga2"]["conf_dir"]}"
#   code <<-EOH
#   cd #{node["icinga2"]["conf_dir"]}
#   ./icinga2_config.py
#   EOH
#   notifies :reload, 'service[icinga2]'
#  end
#end

template "/etc/icinga2/scripts/pagerduty-host-notification.sh" do
 source "pagerduty-host-notification.erb"
 owner node['icinga2']['user']
 group node['icinga2']['user']
 mode 0755
end

template "/etc/icinga2/scripts/pagerduty-service-notification.sh" do
 source "pagerduty-service-notification.erb"
 owner node['icinga2']['user']
 group node['icinga2']['user']
 mode 0755
end

template "#{node["icinga2"]["conf_dir"]}/pagerduty.conf" do
 source "pagerduty.conf.erb"
 owner node['icinga2']['user']
 group node['icinga2']['user']
 mode 0644
end

template "/etc/icinga2/scripts/slack-host-notification.sh" do
 source "slack-host-notification.sh.erb"
 owner node['icinga2']['user']
 group node['icinga2']['group']
 mode 00755
 variables(
    :slack => node['icinga2']['slack'],
  )
 
end

template "/etc/icinga2/scripts/slack-service-notification.sh" do
 source "slack-service-notification.sh.erb"
 owner node['icinga2']['user']
 group node['icinga2']['group']
 mode 00755
 variables(
    :slack => node['icinga2']['slack'],
  )
 
end

template "/usr/local/bin/slack_nagios.pl" do
 source "slack_nagios.pl.erb"
 owner node['icinga2']['user']
 group node['icinga2']['group']
 mode 00755
 variables(
    :slack => node['icinga2']['slack'],
  )
 
end

template "/etc/icinga2/scripts/icinga2-opsworks.sh" do
 source "icinga2-opsworks.sh.erb"
 owner node['icinga2']['user']
 group node['icinga2']['group']
 mode 00755
end

template "#{node["icinga2"]["conf_dir"]}/slack.conf" do
 source "slack.conf.erb"
 owner node['icinga2']['user']
 group node['icinga2']['group']
 mode 00644
 
end

template "/etc/icinga2/scripts/slack-webhook-notification.pl" do
  source "slack_nagios_webhooks.pl.erb"
  owner node['icinga2']['user']
  group node['icinga2']['group']
  mode 00755
  variables({
    :slack => node['icinga2']['slack_webhook'],
  })
end

template "#{node["icinga2"]["conf_dir"]}/slack-webhook.conf" do
  source "slack-webhook.conf.erb"
  owner node['icinga2']['user']
  group node['icinga2']['group']
  mode 00644
  variables({
    :slack => node['icinga2']['slack_webhook'],
  })
  
end

template "/etc/icinga2/scripts/update-icinga.sh" do
 source "update-icinga.sh.erb"
 owner node['icinga2']['user']
 group node['icinga2']['group']
 mode 00755
 variables(
    :stack_id => node[:opsworks].nil? ? '' : node[:opsworks][:stack][:id],
    :node_id  => node[:opsworks].nil? ? '' : node[:opsworks][:instance][:id]
  )
  notifies :restart, 'service[icinga2]', :immediately
end

service 'icinga2' do
 supports :status => true, :restart => true, :reload => true
 action [:start, :enable]
end

service 'httpd' do
 supports :status => true, :restart => true, :reload => true
end

cron "update_icinga" do
   minute '0,30'
   hour '*'
   day '*'
   month '*'
   weekday '*'
   command "/etc/icinga2/scripts/update-icinga.sh"
   action :create
end

cron "refresh_opsworks" do
   minute '0'
   hour '*'
   day '*'
   month '*'
   weekday '*'
   command "/etc/icinga2/scripts/icinga2-opsworks.sh"
   action :create
end
