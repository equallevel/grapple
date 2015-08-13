module Grapple
	module Components
		extend ActiveSupport::Autoload

		autoload :BaseComponent
		autoload :HtmlComponent
		autoload :HtmlRow
		autoload :HtmlHeader
		autoload :HtmlBody
		autoload :HtmlFooter
		autoload :HtmlColgroup
		autoload :ColumnHeadings
		autoload :WillPaginate
		autoload :Toolbar
		autoload :Actions
		autoload :SearchForm
		autoload :SearchQueryField
		autoload :SearchSubmit
		autoload :WillPaginatePagination
		autoload :WillPaginateInfobar

	end
end