module Grapple
	extend ActiveSupport::Autoload

	autoload :Components
	autoload :BaseTableBuilder
	autoload :HtmlTableBuilder
	autoload :DataGridBuilder
	autoload :AjaxDataGridBuilder
	autoload :Helpers
end

require 'grapple/engine' if defined?(::Rails)