# icinga2

To install an icinga2 server you need to run the ops-icinga2::default recipe.

## Cookbook Dependencies

- yum version 3.13.0
You can see the official documentation here
https://supermarket.chef.io/cookbooks/yum/versions/3.13.0

- apt version 2.9.2
You can see the official documentation here
https://supermarket.chef.io/cookbooks/apt/versions/2.9.2

- nrpe version 1.5.3
You can see the official documentation here
https://supermarket.chef.io/cookbooks/nrpe/versions/1.5.3

- python version 1.4.6
You can see the official documentation here
https://supermarket.chef.io/cookbooks/python/versions/1.4.6



Those dependencies are add on the Berksfile parent for the download and on the ops-icinga2/metadata.rb file.


## ops-icinga2::default
We use this recipe to call the others.

```
include_recipe "icinga2::client"
include_recipe "icinga2::install"
include_recipe "icinga2::config"
```


## ops-icinga2::client

This recipe is used to install all the plugins using nagios. The plugins are in the files/default directory, in this cookbook you will can see rabbitmq plugins and pingdom, rds, redis and nginx check scripts. So you can use them like a example or you can remove them if you want. So If you want to monitor another service, you can add the plugin under files/default folder and include it in the client recipe.

Also in this recipe we configure the monitors using by nrpe, something like cpu, load, memory, disk or if a process is alive or not. So you can add or remove some nrpe_checks if you want. Some metric values using here were defined like variables in the attributes file.

## ops-icinga2::install

The install recipe creates the configuration files for each plugin installed in the client recipe. The dynamic values for this configurations are currently in the attributes file, you can remove it or add another ones.

The next templates are using to configure the Icinga2, the conf directory is /etc/icinga2/conf.d

- notifications.conf
- groups.conf
- users.conf
- icinga2.conf

Also we have another template `passwd.erb`, this file contains the http passwords. Finally, the recipe start the apache2, npcd, icinga2 and nagios-nrpe-server services.

## ops-icinga2::config

This recipe is using mainly for configure alerts. So this recipe creates the templates to set notifications to slack and pagerduty. The configuration variables are in the attrbutes file.

In this recipe we have two cron instructions, the first one is used to execute this recipe every a half hour (1:30, 2:30, 3:30...) and update the values for the Icinga2 server. The second run /etc/icinga2/conf.d/icinga2_opsworks.py, this file search all the instances in the same layer and call to icinga2_config.py on each one who execute the cfg files in the instance and this process is repeat it each hour.

## Attributes

<table>
  <tr>
    <th>Variable</th>
    <th>Description</th>
  </tr>
  <tr>
  <td>default["icinga2"]["user"]</td>
  <td>User name for incinga2, nagios by default</td>
  </tr>
  <tr>
  <td>default["icinga2"]["group"]</td>
  <td>Group name for incinga2, nagios by default</td>
  </tr>
  <tr>
  <td>default["icinga2"]["apache_user"]</td>
  <td>Apache username, www-data by default</td>
  </tr>
  <tr>
  <td>default["icinga2"]["apache_group"]</td>
  <td>Apache group name, www-data by default</td>
  </tr>
  <tr>
  <td>default["icinga2"]["conf_dir"]</td>
  <td>Config directoy, all the config files will be here. /etc/icinga2/conf.d by default </td>
  </tr>
  <tr>
  <td>default['icinga2']['server']['packages'] </td>
  <td>Packages names to install</td>
  </tr>
  <tr>
  <td>default['nrpe']['allowed_hosts']</td>
  <td>List of allowed hosts, 127.0.0.1,10.0.0.0/8 by default</td>
  </tr>
  <tr>
  <td>default['nrpe']['install_method']</td>
  <td>Kind of intall method, package by default</td>
  </tr>
  <tr>
  <td>default['nrpe']['plugindir']</td>
  <td>Folder where the nagios plugins will be</td>
  </tr>
  <tr>
  <td>default['icinga2']['check_load']['warning']</td>
  <td>Threshold for a warning</td>
  </tr>
  <tr>
  <td>default['icinga2']['check_load']['critical']</td>
  <td>Threshold for a critical alert</td>
  </tr>
  <tr>
  <td>default['icinga2']['check_ntp_time']['warning']</td>
  <td>Warning condition</td>
  </tr>
  <tr>
  <td>default['icinga2']['check_ntp_time']['critical']</td>
  <td>Critical alert condition</td>
  </tr>
  <tr>
  <td>default['icinga2']['check_ntp_time']['ntp_host']</td>
  <td>ntp host</td>
  </tr>
  <tr>
  <td>default['icinga2']['slack']['channel']['id']</td>
  <td>Name of the slack's channel, #icinga-nclouds for example (nagios notifications)</td>
  </tr>
  <tr>
  <td>default['icinga2']['slack']['domain']</td>
  <td>Domain, nclouds.slack.com for example (nagios notifications)</td>
  </tr>
  <tr>
  <td>default['icinga2']['slack']['token']</td>
  <td>Slack token (nagios notifications)</td>
  </tr>
  <tr>
  <td>default['icinga2']['slack_webhook']['url']</td>
  <td>Slack web hook url (icinga2 notifications)</td>
  </tr>
  <tr>
  <td>default['icinga2']['slack_webhook']['channel']</td>
  <td>Slack channel (icinga2 notifications)</td>
  </tr>
  <tr>
  <td>default['icinga2']['pagerdury']['service_key']['nclouds']</td>
  <td>Key for pagerduty, you can add more variable like this but you need to add it to into the pagerduty-host-notification template</td>
  </tr>
  <tr>
  <td>default['icinga2']['user']['admin']['email']</td>
  <td>admin email</td>
  </tr>
  <tr>
  <td>default['pingdom']['email']</td>
  <td>Pingdom email</td>
  </tr>
  <tr>
  <td>default['pingdom']['pass']</td>
  <td>Pingdom password</td>
  </tr>
  <tr>
  <td>default['pingdom']['api']</td>
  <td>Pingdom api key</td>
  </tr>
  <tr>
  <td>default['icinga2']['rds']['db_identifier']</td>
  <td>RDS identifier</td>
  </tr>
</table>
