
describe 'scrutinizer-whitelist::default' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache') do |node|
      node.set['scrutinizer-whitelist']['source-url'] = 'https://foo.bar'
      node.set['scrutinizer-whitelist']['priority'] = '99'
    end.converge(described_recipe)
  end

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('/var/chef/cache/scrutinizer_ips.json').and_return <<EOF
{
  "hook_ips": [
    "1.2.3.4",
    "5.6.7.8"
  ],
  "pull_ips": [
    "1.2.3.4",
    "5.6.7.8"
  ]
}
EOF
  end

  it 'should fetch the list if whitelist IPs from the scrutinizer API' do
    expect(chef_run).to create_remote_file('/var/chef/cache/scrutinizer_ips.json').with(source: 'https://foo.bar')
  end

  it 'should include the iptables cookbook' do
    expect(chef_run).to include_recipe('iptables-ng')
  end

  it 'should delete an existing scrutinizer firewall chain' do
    expect(chef_run).to delete_iptables_ng_chain('SCRUTINIZER-FIREWALL delete').with(chain: 'SCRUTINIZER-FIREWALL')
  end

  it 'should create a new scrutinizer firewall chain' do
    expect(chef_run).to create_iptables_ng_chain('SCRUTINIZER-FIREWALL create').with(
      chain: 'SCRUTINIZER-FIREWALL',
      policy: 'FORWARD [0:0]'
    )
  end

  it 'should add the new chain to the INPUT with the configured priority' do
    expect(chef_run).to create_if_missing_iptables_ng_rule('99-SCRUTINIZER-FIREWALL').with(
      rule: '--jump SCRUTINIZER-FIREWALL'
    )
  end

  it 'should add rules for the IP addresses in the file' do
    expect(chef_run).to create_iptables_ng_rule('ipaddresses').with(
      chain: 'SCRUTINIZER-FIREWALL',
      ip_version: 4,
      rule: %w(1.2.3.4 5.6.7.8).map { |ip| "--source #{ip} --protocol tcp --dport 22 --jump ACCEPT" }
    )
  end
end
