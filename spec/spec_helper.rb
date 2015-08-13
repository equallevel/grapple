require 'rubygems'
require 'bundler/setup'
require 'will_paginate'
require 'active_support'
require 'action_pack'
require 'action_view'
require 'action_controller'
require 'action_dispatch'
require 'rails'
require 'active_record'
require 'active_record/version'
require 'active_record/fixtures'

require 'will_paginate/active_record'
require 'will_paginate/view_helpers/action_view'

require_relative '../lib/grapple'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories in alphabetic order.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each {|f| require f}


puts "Rails v#{Rails.version}"

FIXTURES_PATH = File.expand_path('../fixtures', __FILE__)

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")


#ActiveRecord::Base.silence do
	ActiveRecord::Migration.verbose = false
	load File.join(FIXTURES_PATH, 'schema.rb')
#end

Fixtures = defined?(ActiveRecord::FixtureSet) ? ActiveRecord::FixtureSet :
             defined?(ActiveRecord::Fixtures) ? ActiveRecord::Fixtures :
             ::Fixtures
						 
Fixtures.create_fixtures FIXTURES_PATH, ['users']

class User < ActiveRecord::Base
	
end
	
require 'will_paginate'

module FakeHelpersModule
end

module GrappleSpecHelper
	include ActionPack
	include ActionView::Context if defined?(ActionView::Context)
	include ActionController::RecordIdentifier if defined?(ActionController::RecordIdentifier)
	include ActionView::Helpers::FormHelper
	include ActionView::Helpers::FormTagHelper
	include ActionView::Helpers::FormOptionsHelper
	include ActionView::Helpers::UrlHelper
	include ActionView::Helpers::TagHelper
	include ActionView::Helpers::TextHelper
	include ActionView::Helpers::ActiveRecordHelper if defined?(ActionView::Helpers::ActiveRecordHelper)
	include ActionView::Helpers::ActiveModelHelper if defined?(ActionView::Helpers::ActiveModelHelper)
	include ActionView::Helpers::DateHelper
	include ActionView::Helpers::CaptureHelper
	include ActionView::Helpers::AssetTagHelper
	include ActiveSupport
	include ActionController::PolymorphicRoutes if defined?(ActionController::PolymorphicRoutes)
	include ActionDispatch::Routing::PolymorphicRoutes 
	include AbstractController::UrlFor if defined?(AbstractController::UrlFor)
	include ActionView::RecordIdentifier if defined?(ActionView::RecordIdentifier)
	include WillPaginate::ActionView
	
	USERS_COLUMNS = [
		{ label: '' },
		{ label: 'first name', sort: 'firstname', width: 140 },
		{ label: 'last name', sort: 'lastname', width: 140 },
		{ label: 'username', sort: 'login', width: 150 },
		{ label: 'email', sort: 'email', width: 300 },
		{ label: 'Created At', sort: 'created_at', width: 175 }
	]
	
	def users_columns
		USERS_COLUMNS
	end
	
	def users_records
		User.all.paginate({ page: 1, per_page: 3 })
	end
	
	def default_url_options
		{}
	end
	
	def _routes
		url_helpers = double('url_helpers')
		allow(url_helpers).to receive(:hash_for_users_path).and_return({})
		allow(url_helpers).to receive(:hash_for_user_path).and_return({})
		#url_helpers.stub(:hash_for_user_path).and_return({})

		double('_routes',
			:url_helpers => url_helpers,
			:url_for => "/mock/path"
		)
	end

	def controller
		env = double('env', :[] => nil)
    request = double('request', :env => env)
    double('controller', :controller_path= => '', :params => {}, :request => request)
  end

	def mock_everything
		# Resource-oriented styles like form_for(@post) will expect a path method for the object,
		# so we're defining some here.
		def user_path(*args); "/users/1"; end
		def users_path(*args); "/users"; end
		def new_user_path(*args); "/users/new"; end
	end
	
	def self.included(base)
		base.class_eval do

			attr_accessor :output_buffer

			def protect_against_forgery?
				false
			end

			def _helpers
				FakeHelpersModule
			end

		end
	end
	
end

