module Grapple
	class DataGridBuilder < HtmlTableBuilder

		helper :infobar, Grapple::Components::WillPaginateInfobar

		# Toolbar
		helper :search_submit, Grapple::Components::SearchSubmit
		helper :search_query_field, Grapple::Components::SearchQueryField
		helper :search_form, Grapple::Components::SearchForm
		helper :actions, Grapple::Components::Actions
		helper :toolbar, Grapple::Components::Toolbar, components: [:search_form, :actions]

		# Sortable column headings
		helper :column_headings, Grapple::Components::ColumnHeadings

		configure :header, components: [:infobar, :toolbar, :column_headings]

		# Paging
		helper :pagination, Grapple::Components::WillPaginatePagination

		configure :footer, components: [:pagination]

	end
end
