require 'grapple/helpers/table_helper'

module Grapple
	class Engine < Rails::Engine
    initializer 'grapple.initialize' do
      ActiveSupport.on_load(:action_view) do
        include Grapple::Helpers::TableHelper
      end
    end
  end
end
