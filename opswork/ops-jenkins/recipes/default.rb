#
# Cookbook Name:: ops-jenkins
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
#include_recipe 'ops-caddy::default'
include_recipe 'java::oracle'
#include_recipe "ops-base"
include_recipe 'jenkins::master'
include_recipe 'awscli'

package 'jq'

include_recipe "#{cookbook_name}::plugins"

directory '/var/lib/jenkins/.ssh' do
  owner "jenkins"
  group "jenkins"
  mode 0700
  recursive true
  action :create
end

user 'jenkins' do
  shell '/bin/bash'
end

include_recipe 'python'
python_pip "virtualenv"

directory '/var/lib/jenkins/ed' do
  owner 'jenkins'
end

file '/var/lib/jenkins/ed/requirements.txt' do
  content "click==3.3\nbotocore==0.64.0\narrow==0.4.4"
  mode '0755'
  owner 'jenkins'
end

python_virtualenv "/var/lib/jenkins/ed/easydep" do
  owner "jenkins"
  group "jenkins"
  action :create
end

bash "Create virtual env" do
  user "jenkins"
  cwd "/var/lib/jenkins/ed"
  code <<-EOF
    source easydep/bin/activate
    export HOME=/var/lib/jenkins
    pip install -r /var/lib/jenkins/ed/requirements.txt
  EOF
end

cookbook_file '/usr/local/bin/easy_deploy.py' do
  source 'easy_deploy.py'
  mode '0644'
end

#group 'docker' do
#  action :modify
#  members 'jenkins'
#  append true
#end
