default['scrutinizer-whitelist']['source-url'] = 'https://scrutinizer-ci.com/api/meta'
default['scrutinizer-whitelist']['priority'] = '05'
default['scrutinizer-whitelist']['ports'] = [node['sshd']['sshd_config']['Port']]
