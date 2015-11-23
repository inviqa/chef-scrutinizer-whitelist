require 'chefspec'
require 'chefspec/berkshelf'

current_dir = File.dirname(__FILE__)

RSpec.configure do |config|
  config.cookbook_path = File.join(current_dir, '../cookbooks')
end
