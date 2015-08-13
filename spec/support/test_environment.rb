# encoding: utf-8
require 'rspec/core'
require 'rspec-html-matchers'

RSpec.configure do |config|
	config.include RSpecHtmlMatchers
	config.mock_with :rspec
end

require 'action_controller/railtie'
require 'active_model'

# Create a simple rails application for use in testing the viewhelper
module GrappleTest
	class Application < Rails::Application
		# Configure the default encoding used in templates for Ruby 1.9.
		config.encoding = "utf-8"
		config.active_support.deprecation = :stderr
		config.secret_key_base = "secret"
		config.eager_load = false
	end
end
GrappleTest::Application.initialize!

require 'rspec/rails'

# Quick hack to avoid the 'Spec' deprecation warnings from rspec_tag_matchers
module Spec
	include RSpec
end
