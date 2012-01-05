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
require 'action_pack/version'
require 'nokogiri/diff'




$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'navigation_builder'

module CustomAssertions
  def assert_generated_markup
    test_inputs = OpenStruct.new(:tempate => "", :expected => "")
    yield test_inputs
    render :inline => test_inputs.template

    expected_dom = Nokogiri::XML(test_inputs.expected)
    rendered_dom = Nokogiri::XML(rendered)

    different = expected_dom.diff(rendered_dom).any? do |change, node|
      # we are looking for anything that's an actual difference (change will be
      # + or -) and the content of the difference is more than just whitespace
      change != " " && node.content.strip != ""
    end

    assert !different, <<-EOS
      generated and expected HTML differ
      ======== Generated ========
      #{rendered}
      ======== Expected  ========
      #{test_inputs.expected}
      EOS
  end
end
