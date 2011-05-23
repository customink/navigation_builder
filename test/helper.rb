require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'redgreen'
require 'shoulda'

# require 'active_support/deprecation' # For Rails 3
require 'action_pack'
require 'action_view'
require 'action_controller' # For Rails 2

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'navigation_builder'

class Test::Unit::TestCase
end
