#
# Cookbook Name:: icinga2
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

#include_recipe "ops-base"
include_recipe "#{cookbook_name}::client"
include_recipe "#{cookbook_name}::install"
include_recipe "#{cookbook_name}::config"
#include_recipe "ops-route53_autoupdate"
