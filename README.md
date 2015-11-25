# scrutinizer-whitelist

[![](https://travis-ci.org/inviqa/chef-scrutinizer-whitelist.svg?branch=master)](https://travis-ci.org/inviqa/chef-scrutinizer-whitelist)

This cookbook provides iptables rules to grant access to the Scrutinizer CI platform, via the [iptables-ng](https://github.com/chr4-cookbooks/iptables-ng) cookbook.

## Usage

Include `scrutinzer-whitelist` in your run list.

### Attributes

- `['scrutinizer-whitelist']['source-url']` - The URL of the API endpoint where the IPs can be retrieved. Default `"https://scrutinizer-ci.com/api/meta"`.
- `['scrutinizer-whitelist']['priority']` - The priority at which to apply the rules. Ensure this is a lower number than any blocking rules. Default `"05"`.
- `['scrutinizer-whitelist']['ports']` - List of port numbers to open. Default `[22]`.

## Contributing

Comments, issues and pull requests are all welcome.

To get started working on the repo; fork it, clone it, install the gems and run the tests:
 
    bundle install
    bundle exec rake test

## License and Author

Author:: Shane Auckland (sauckland@inviqa.com)

Copyright 2015, Inviqa

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
