#
# Cookbook Name:: scrutinizer-whitelist
# Recipe:: default
#
# Copyright (c) 2015 Inviqa, All Rights Reserved.
#

ip_json_file = "#{Chef::Config['file_cache_path']}/scrutinizer_ips.json"

remote_file ip_json_file do
  source node['scrutinizer-whitelist']['source-url']
end.run_action(:create)

include_recipe 'iptables-ng'

ips = JSON.parse(File.read(ip_json_file))

iptables_ng_chain 'SCRUTINIZER-FIREWALL' do
  policy 'RETURN [0:0]'
end

iptables_ng_rule "#{node['scrutinizer-whitelist']['priority']}-SCRUTINIZER-FIREWALL" do
  rule '--jump SCRUTINIZER-FIREWALL'
  action :create_if_missing
end

iptables_ng_rule 'scrutinizer ipaddresses' do
  chain 'SCRUTINIZER-FIREWALL'
  ip_version 4
  rule ips['hook_ips'].map { |ip|
    "--source #{ip} --protocol tcp --dport 22 --jump ACCEPT"
  }
end
