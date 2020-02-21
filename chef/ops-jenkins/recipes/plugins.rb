jenkins_plugin 'git' do
  notifies :restart, 'service[jenkins]', :immediately
  #action :install
  ignore_failure true
end

jenkins_plugin 'git-client'  do
  notifies :restart, 'service[jenkins]', :immediately
  #action :install
  ignore_failure true
end

jenkins_plugin 'slack' do
  notifies :restart, 'service[jenkins]', :immediately
  #action :install
  ignore_failure true
end
