#
# Cookbook Name:: icinga2
# Recipe:: install
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'apt::default'

case node['platform']
when 'debian', 'ubuntu'

  bash "Pre-Set password for icinga" do
    code 'echo "icinga2-classicui icinga2-classicui/adminpassword-repeatpassword this_password_will_be_change" | debconf-set-selections'
  end

  apt_repository "icinga-stable-release" do
    #uri "http://ppa.launchpad.net/formorer/icinga/ubuntu"
    uri "http://packages.icinga.org/ubuntu"
    distribution "icinga-#{node['lsb']['codename']}"
    components ["main"]
    key "http://packages.icinga.org/icinga.key"
  end
  # https://wiki.icinga.org/display/howtos/Setting+up+NRPE+with+Icinga#SettingupNRPEwithIcinga-Setup
  apt_package 'nagios-nrpe-plugin' do
    action :install
    options '--no-install-recommends'
  end
  package 'libwww-perl'
  package 'libcrypt-ssleay-perl'

  apt_repository "pd-agent-release" do
    uri 'http://packages.pagerduty.com/pdagent'
    distribution "deb/" #{node['lsb']['codename']}"
    #components ["main"]
    key "http://packages.pagerduty.com/GPG-KEY-pagerduty"
  end

  package 'pnp4nagios'

  cookbook_file '/etc/default/npcd' do
    source 'pnp/npcd'
    notifies :restart, 'service[npcd]', :delayed
  end

  bash 'Enable perf data' do
    code 'icinga2 feature enable perfdata || update-rc.d npcd enable'
    notifies :restart, 'service[npcd]', :delayed
  end

  package 'pdagent'
  package 'pdagent-integrations'
when 'redhat', 'centos', 'fedora'
  include_recipe 'yum'
  yum_repository 'icinga-stable-release' do
    description "icinga-stable-release"
    baseurl "http://packages.icinga.org/epel/6/release/"
    gpgkey 'http://packages.icinga.org/icinga.key'
    action :create
  end
end

node['icinga2']['server']['packages'].each do |pkg|
  package pkg
end

template "/etc/icinga2/icinga2.conf" do
  source "icinga2.conf.erb"
  owner node['icinga2']['user']
  group node['icinga2']['group']
  mode "0640"
  notifies :reload, 'service[icinga2]'
end
template "#{node["icinga2"]["conf_dir"]}/users.conf" do
  source "users.conf.erb"
  owner node['icinga2']['user']
  group node['icinga2']['user']
  mode 0640
  notifies :reload, 'service[icinga2]'
end
template "#{node["icinga2"]["conf_dir"]}/groups.conf" do
  source "groups.conf.erb"
  owner node['icinga2']['user']
  group node['icinga2']['user']
  mode 0640
  notifies :reload, 'service[icinga2]'
end
template "#{node["icinga2"]["conf_dir"]}/notifications.conf" do
    owner node['icinga2']['user']
    group node['icinga2']['group']
    source "notifications.conf.erb"
    mode 00644
    notifies :reload, 'service[icinga2]'
  end
template "/etc/icinga2-classicui/htpasswd.users" do
  source "passwd.erb"
  owner node['icinga2']['user']
  group node['icinga2']['apache_group']
  mode 0640
end
template "/etc/icinga2/cgi.cfg" do
  source "cgi.cfg.erb"
  owner node['icinga2']['user']
  group node['icinga2']['apache_group']
  mode 0640
  notifies :reload, 'service[httpd]'
end
template "/usr/lib/nagios/plugins/check_dynamodb.py" do
  source "check_dynamodb.py.erb"
  mode 0755
  notifies :reload, 'service[icinga2]'
end

link '/etc/apache2/sites-enabled/002-icinga-classicui.conf' do
  to '/etc/icinga2-classicui/apache2.conf'
  notifies :reload, 'service[httpd]'
end

template '/etc/pnp4nagios/apache.conf' do
  source 'pnp/apache.conf.erb'
end
template '/etc/pnp4nagios/npcd.cfg' do
  source 'pnp/npcd.cfg.erb'
  notifies :restart, 'service[npcd]'
end

template '/etc/icinga2/conf.d/pnp.conf' do
  source 'pnp.conf.erb'
  notifies :restart, 'service[icinga2]'
end

template '/etc/icinga2/conf.d/pingdom.conf' do
  source 'pingdom.conf.erb'
  notifies :restart, 'service[icinga2]'
end

template '/etc/icinga2/conf.d/rds.conf' do
  source 'rds.conf.erb'
  notifies :restart, 'service[icinga2]'
  variables({
    :dbidentifies => node['icinga2']['rds']['db_identifier'].map { |i| "\"#{i}\"" }.join(",")
  })
end

link '/etc/apache2/sites-enabled/003-pnp.conf' do
  to '/etc/pnp4nagios/apache.conf'
  notifies :reload, 'service[httpd]'
end

##service httpd
service 'httpd' do
  service_name "apache2"
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

service 'npcd' do
  service_name "npcd"
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
##service icinga2
service 'icinga2' do
  service_name "icinga2"
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

service 'nagios-nrpe-server' do
  service_name "nagios-nrpe-server"
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
