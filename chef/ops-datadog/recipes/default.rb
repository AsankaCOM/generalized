
bash 'Install_datadog_agent' do
  code <<-EOF
    DD_API_KEY=#{node['datadog']['DD_API_KEY']} bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"
    EOF
end

service 'datadog-agent' do
  action [:enable, :start]
end
