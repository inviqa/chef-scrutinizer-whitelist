name 'scrutinizer-whitelist'
maintainer 'Inviqa'
maintainer_email 'support@inviqa.com'
license 'Apache'
description 'Provides firewall access rules for Scrutinizer'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'

depends 'iptables-ng', '~> 2.2.0'
depends 'sshd', '~> 1.1.1'
