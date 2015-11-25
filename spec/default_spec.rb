api_response = <<EOF
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

describe 'scrutinizer-whitelist::default' do
  context 'default config' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache') do |node|
        node.set['sshd']['sshd_config']['Port'] = 22
      end.converge(described_recipe)
    end

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with('/var/chef/cache/scrutinizer_ips.json').and_return api_response
    end

    it 'should fetch the list if whitelist IPs from the scrutinizer API' do
      expect(chef_run).to create_remote_file('/var/chef/cache/scrutinizer_ips.json').with(
        source: 'https://scrutinizer-ci.com/api/meta'
      )
    end

    it 'should include the iptables cookbook' do
      expect(chef_run).to include_recipe('iptables-ng')
    end

    it 'should create a new scrutinizer firewall chain' do
      expect(chef_run).to create_iptables_ng_chain('SCRUTINIZER-FIREWALL')
    end

    it 'should add the new chain to the INPUT with the configured priority' do
      expect(chef_run).to create_iptables_ng_rule('05-SCRUTINIZER-FIREWALL').with(
        rule: '--protocol tcp --match multiport --destination-ports 22 --jump SCRUTINIZER-FIREWALL'
      )
    end

    it 'should add rules for the IP addresses in the file' do
      expect(chef_run).to create_iptables_ng_rule('scrutinizer-ipaddresses').with(
        chain: 'SCRUTINIZER-FIREWALL',
        ip_version: 4,
        rule: %w(1.2.3.4 5.6.7.8).map { |ip| "--source #{ip} --jump ACCEPT" }
      )
    end
  end

  context 'overridden config values' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache') do |node|
        node.set['scrutinizer-whitelist']['source-url'] = 'https://foo.bar'
        node.set['scrutinizer-whitelist']['priority'] = '99'
        node.set['scrutinizer-whitelist']['ports'] = [22, 23, 24]
      end.converge(described_recipe)
    end

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with('/var/chef/cache/scrutinizer_ips.json').and_return api_response
    end

    it 'should allow the API URL to be configured' do
      expect(chef_run).to create_remote_file('/var/chef/cache/scrutinizer_ips.json').with(source: 'https://foo.bar')
    end

    it 'should allow the priority to be configured' do
      expect(chef_run).to create_iptables_ng_rule('99-SCRUTINIZER-FIREWALL')
    end

    it 'should allow the enabled ports to be configured' do
      expect(chef_run).to create_iptables_ng_rule('99-SCRUTINIZER-FIREWALL').with(
        rule: '--protocol tcp --match multiport --destination-ports 22,23,24 --jump SCRUTINIZER-FIREWALL'
      )
    end
  end

  context 'different sshd port config is inherited' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(file_cache_path: '/var/chef/cache') do |node|
        node.set['sshd']['sshd_config']['Port'] = 999
      end.converge(described_recipe)
    end

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with('/var/chef/cache/scrutinizer_ips.json').and_return api_response
    end

    it 'should use the inherited sshd port config' do
      expect(chef_run).to create_iptables_ng_rule('05-SCRUTINIZER-FIREWALL').with(
        rule: '--protocol tcp --match multiport --destination-ports 999 --jump SCRUTINIZER-FIREWALL'
      )
    end
  end
end
