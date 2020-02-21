#default["icinga2"]["user"] = "icinga"
#default["icinga2"]["group"] = "icinga"
default["icinga2"]["user"] = "nagios"
default["icinga2"]["group"] = "nagios"
default["icinga2"]["apache_user"] = "www-data"
default["icinga2"]["apache_group"] = "www-data"


default["icinga2"]["conf_dir"]="/etc/icinga2/conf.d"
#default['icinga2']['server']['packages'] = %w( icinga2 icinga2-classicui-config icinga-gui nagios-plugins-all nagios-plugins-nrpe mailx )
default['icinga2']['server']['packages'] = %w( icinga2 nagios-plugins nagios-nrpe-server mailutils icinga2-classicui)

default['nrpe']['allowed_hosts']  = [ "127.0.0.1,10.0.0.0/8"]
default['nrpe']['install_method'] = 'package'
default['nrpe']['dont_blame_nrpe'] = 1

case node['platform']
when 'debian', 'ubuntu'
  default['nrpe']['plugindir'] = "/usr/lib/nagios/plugins/"
when 'redhat', 'centos', 'fedora'
  default['nrpe']['plugindir'] = "/usr/lib64/nagios/plugins/"
end

total_cpu = node['cpu']['total']
default['icinga2']['check_load']['warning'] =  "#{total_cpu * 2 + 10},#{total_cpu * 2 + 5},#{total_cpu}"
default['icinga2']['check_load']['critical'] = "#{total_cpu * 4 + 10},#{total_cpu * 4 + 5},#{total_cpu * 2}"

default['icinga2']['check_ntp_time']['warning'] = 15
default['icinga2']['check_ntp_time']['critical'] = 60
default['icinga2']['check_ntp_time']['ntp_host'] = "3.amazon.pool.ntp.org"

default['icinga2']['slack']['channel']['id'] = ""
default['icinga2']['slack']['domain'] = ""
default['icinga2']['slack']['token'] = ""

default['icinga2']['slack_webhook']['url'] = ""
default['icinga2']['slack_webhook']['channel'] = ""
default['icina2']['user']['admin']['email'] = "root@localhost"

#default['icinga2']['pagerdury']['service_key']['nclouds'] = node[:deploy]['WellpassApp'][:environment_variables]['PAGERDUTY_SERVICEKEY_NCLOUDS']
#default['icinga2']['pagerdury']['service_key']['wellpass'] = node[:deploy]['WellpassApp'][:environment_variables]['PAGERDUTY_SERVICEKEY_WELLPASS']

###########################################################
#You can add here more attributes to monitor other services
###########################################################

default['icinga2']['pagerdury']['service_key']['nclouds'] = "9e5f3b04f1d643cbb7858e56f17cd852"

default['pingdom']['email'] = ""
default['pingdom']['pass'] = ""
default['pingdom']['api'] = ""

default['icinga2']['rds']['db_identifier'] = ['prd-rds'] #, 'stag-rds-replica1']
