require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'ostruct'

require 'test/unit'
require 'redgreen'
require 'shoulda'

# require 'active_support/deprecation' # For Rails 3
require 'action_controller'
require 'action_view'
require 'action_view/test_case'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'navigation_builder'

module CustomAssertions
  def assert_generated_markup
    test_inputs = OpenStruct.new(:tempate => "", :expected => "")
    yield test_inputs
    render :inline => test_inputs.template
    assert_dom_equal test_inputs.expected, rendered
  end
end
