#
# Cookbook Name:: icinga2
# Recipe:: client
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'python'
include_recipe 'nrpe'

case node['platform_family']
when 'rhel'
  # do things on RHEL platforms (redhat, centos, scientific, etc)
  execute 'install openfusion repo' do
    command 'rpm -Uvh http://repo.openfusion.net/centos7-x86_64/openfusion-release-0.7-1.of.el7.noarch.rpm'
    action :run
    not_if 'rpm -qa | grep openfusion'
  end
  nagios_nrpe_plugin = "nagios-plugins-nrpe"
  nagios_nrpe_plugin_options = ''
  packages = %w{ nagios-plugins-perl nagios-plugins nagios-plugins-all perl-JSON perl-Sys-Statistics-Linux perl-LWP-Protocol-https }

else
  # do things on debian-ish platforms (debian, ubuntu, linuxmint)
  nagios_nrpe_plugin = "nagios-nrpe-plugin"
  nagios_nrpe_plugin_options = '--no-install-recommends'
  packages = %w{ libnagios-plugin-perl nagios-plugins nagios-plugins-common nagios-plugins-standard nagios-plugins-contrib nagios-plugins-extra libjson-perl libsys-statistics-linux-perl liblwp-protocol-https-perl }
end

packages.each do |pkg|
 package pkg
end



#####################################################
####### HERE START THE INSTALLATIONS OF THE PLUGINS
#####################################################

python_pip 'nagioscheck'

python_pip 'nagios-plugin-elasticsearch'

directory "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq" do
  mode 0775
  owner 'root'
  group 'root'
  action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_aliveness" do
  source "nagios-plugins-rabbitmq/check_rabbitmq_aliveness"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_connections" do
  source "nagios-plugins-rabbitmq/check_rabbitmq_connections"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_objects" do
  source "nagios-plugins-rabbitmq/check_rabbitmq_objects"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_overview" do
  source "nagios-plugins-rabbitmq/check_rabbitmq_overview"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_partition" do
  source "nagios-plugins-rabbitmq/check_rabbitmq_partition"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_queue" do
  source "nagios-plugins-rabbitmq/check_rabbitmq_queue"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_server" do
  source "nagios-plugins-rabbitmq/check_rabbitmq_server"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_shovels" do
  source "nagios-plugins-rabbitmq/check_rabbitmq_shovels"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_watermark" do
  source "nagios-plugins-rabbitmq/check_rabbitmq_watermark"
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

#cookbook_file "#{node['nrpe']['plugin_dir']}/check_workers.py" do
# source "check_workers.py"
# mode 0755
# action :create
#end

cookbook_file "#{node['nrpe']['plugin_dir']}/check_redis.py" do
 source "check-scripts/check_redis.py"
 mode 0755
 action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/check_redis_key" do
 source "check-scripts/check_redis_key"
 mode 0755
 action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/check_nginx_status.pl" do
 source "check-scripts/check_nginx_status.pl"
 mode 0755
 action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/pingdom" do
 source "check-scripts/pingdom"
 mode 0755
 action :create
end

cookbook_file "#{node['nrpe']['plugin_dir']}/rds" do
 source "check-scripts/rds"
 mode 0755
 action :create
end



cookbook_file "#{node['nrpe']['plugin_dir']}/check_apache.pl" do
 source "check_apache.pl"
 mode 0755
 action :create
end


#####################################################
####### HERE START THE CONFIGURATION FOR NRPE CHECKS
#####################################################

template "#{node['nrpe']['plugin_dir']}/check_linux_stats.pl" do
 source "check_linux_stats.pl.erb"
 mode 0755
end

nrpe_check "check_ntp_time" do
  command "#{node['nrpe']['plugin_dir']}/check_ntp_time"
  warning_condition node['icinga2']['check_ntp_time']['warning']
  critical_condition node['icinga2']['check_ntp_time']['critical']
  parameters "-H #{node['icinga2']['check_ntp_time']['ntp_host']}"
  action :add
end

nrpe_check "check_load" do
  command "#{node['nrpe']['plugin_dir']}/check_load"
  warning_condition node['icinga2']['check_load']['warning']
  critical_condition node['icinga2']['check_load']['critical']
  action :add
end

nrpe_check "check_http" do
  command "#{node['nrpe']['plugin_dir']}/check_http"
  action :add
end

nrpe_check "check_url" do
  command "#{node['nrpe']['plugin_dir']}/check_http"
	parameters "-H $ARG1$ -I $ARG2$ -p $ARG3$"
  action :add
end

#nrpe_check "check_workers" do
#  command "#{node['nrpe']['plugin_dir']}/check_workers.py"
#  parameters "-s $ARG1$ -f $ARG2$ -e $ARG3$"
#  action :add
#end

nrpe_check "check_ssl_cert" do
  command "#{node['nrpe']['plugin_dir']}/check_http"
  parameters "-H 127.0.0.1 -P 443 -C 30 --ssl"
  action :add
end

nrpe_check "check_all_disks" do
  command "#{node['nrpe']['plugin_dir']}/check_disk"
  warning_condition "10%"
  critical_condition "10%"
  parameters "-A -x /dev/shm -X nfs -i /boot -x /efs"
  action :add
end

nrpe_check "check_open_file" do
  command "#{node['nrpe']['plugin_dir']}/check_linux_stats.pl"
  parameters "-F -w 50000,9000000 -c 100000,9000000"
  action :add
end

nrpe_check "check_io" do
  command "#{node['nrpe']['plugin_dir']}/check_linux_stats.pl"
  parameters "-I -w 2000,600 -c 3000,800 -p sda1,sda3,sda4 -s 5"
  action :add
end

nrpe_check "check_mem" do
  command "#{node['nrpe']['plugin_dir']}/check_linux_stats.pl"
  parameters "-M -w 100,98 -c 100,100"
  action :add
end

nrpe_check "check_mem_custom" do
  command "#{node['nrpe']['plugin_dir']}/check_linux_stats.pl"
  parameters "-M -w $ARG1$ -c $ARG2$"
  action :add
end

nrpe_check "check_uptime" do
  command "#{node['nrpe']['plugin_dir']}/check_linux_stats.pl"
  parameters "-U -w 5"
  action :add
end

nrpe_check "check_cpu" do
  command "#{node['nrpe']['plugin_dir']}/check_linux_stats.pl"
  parameters "-C -w 99 -c 100 -s 5"
  action :add
end

nrpe_check "check_es_proc" do
  command "#{node['nrpe']['plugin_dir']}/check_procs -C java -a  'elasticsearch' -c 1:1"
  action :add
end

nrpe_check "check_es_status" do
  command "/usr/local/bin/check_elasticsearch"
	parameters "-H $ARG1$"
  action :add
end

nrpe_check "check_redis" do
  command "#{node['nrpe']['plugin_dir']}/check_redis.py"
	parameters "-s $ARG1$ -p $ARG2$ -w $ARG3$ -c $ARG4$"
  action :add
end

nrpe_check "check_redis_key" do
  command "#{node['nrpe']['plugin_dir']}/check_redis_key"
  action :add
end

nrpe_check "check_apache_http" do
  command "#{node['nrpe']['plugin_dir']}/check_apache.pl"
	parameters "-H $HOSTADDRESS$ -P $ARG1$ -m $ARG2$ -w $ARG3$ -c $ARG4$"
  action :add
end

nrpe_check "check_apache_https" do
  command "#{node['nrpe']['plugin_dir']}/check_apache.pl"
	parameters "-H localhost -P $ARG1$ -m $ARG2$ -w $ARG3$ -c $ARG4$ -S"
  action :add
end

nrpe_check "check_rabbitmq_aliveness" do
  command "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_aliveness"
	parameters "-H localhost"
  action :add
end

nrpe_check "check_rabbitmq_objects" do
  command "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_objects"
	parameters "-H localhost"
  action :add
end

nrpe_check "check_rabbitmq_overview" do
  command "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_overview"
	parameters "-H localhost --username $ARG1$ --pass $ARG2$"
  action :add
end

nrpe_check "check_rabbitmq_statistics" do
  command "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_server"
	parameters "-H localhost --username $ARG1$ --pass $ARG2$"
  action :add
end

nrpe_check "check_rabbitmq_queue" do
  command "#{node['nrpe']['plugin_dir']}/nagios-plugins-rabbitmq/check_rabbitmq_queue"
	parameters "-H localhost --queue $ARG1$"
  action :add
end

nrpe_check "check_celery_proc" do
  command "#{node['nrpe']['plugin_dir']}/check_procs -C python -a  'celery worker' -c 1:1024"
  action :add
end

nrpe_check "check_rabbitmq_proc" do
  command "#{node['nrpe']['plugin_dir']}/check_procs -C beam -a  '/usr/lib/rabbitmq/lib/rabbitmq_server' -c 1:1024"
  action :add
end

nrpe_check "check_tcp" do
  command "#{node['nrpe']['plugin_dir']}/check_tcp"
	parameters "-H $ARG1$ -p $ARG2$"
  action :add
end

nrpe_check "check_procs" do
  command "#{node['nrpe']['plugin_dir']}/check_procs"
	parameters "-C $ARG1$ -a  '$ARG2$' -c 1:$ARG3$"
  action :add
end

nrpe_check "check_procs_no_args" do
  command "#{node['nrpe']['plugin_dir']}/check_procs"
	parameters "-C $ARG1$ -c 1:$ARG2$"
  action :add
end

nrpe_check "check_nginx_status" do
  command "#{node['nrpe']['plugin_dir']}/check_nginx_status.pl"
	parameters "-H $ARG1$ -p $ARG2$"
  action :add
end
