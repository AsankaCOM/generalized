#
# Cookbook Name:: ops-vpn
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#
chef_gem "ruby-shadow" do
  action :install
end
package='openvpn-as-2.0.24-Ubuntu14.amd_64.deb'

remote_file "/tmp/#{package}" do
  source "http://swupdate.openvpn.org/as/openvpn-as-2.0.24-Ubuntu14.amd_64.deb"
  action :create
end

dpkg_package "openvpn-as" do
  source "/tmp/#{package}"
  action :install
  not_if 'dpkg --get-selections  | grep openvpn-as'
end

service 'openvpnas' do
   action [:enable, :start]
end

if !::File.exists?('/usr/local/openvpn_as/.openvpn-modified')
  user 'openvpn' do
    action :modify
    password node['openvpn']['password']
  end
end

file '/usr/local/openvpn_as/.openvpn-modified' do
  content 'modified'
end

include_recipe "#{cookbook_name}::alert"
include_recipe "#{cookbook_name}::dump"
