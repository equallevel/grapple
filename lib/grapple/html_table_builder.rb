module Grapple

	class HtmlTableBuilder < BaseTableBuilder

		# Standard HTML table elements
		helper :caption, Grapple::Components::HtmlCaption
		helper :row, Grapple::Components::HtmlRow
		helper :colgroup, Grapple::Components::HtmlColgroup
		helper :header, Grapple::Components::HtmlHeader
		helper :body, Grapple::Components::HtmlBody
		helper :footer, Grapple::Components::HtmlFooter

		# Row components
		helper :row_menu, Grapple::Components::RowMenu
		helper :identifier_cell, Grapple::Components::IdentifierCell

		# The toolbar and count render above the data table and the pagination below it, so the
		# data table can scroll horizontally on its own
		def table(content, attributes = {})
			html = ''
			html << controls_html
			html << template.content_tag('div', template.content_tag('table', content, attributes), class: 'grapple-scroll')
			html << "\n"
			html << pagination_html
			html.html_safe
		end
		
		# Wrap the table in a div
		def container(inner_html)
			html = ''
			html << before_container
			html << template.tag('div', container_attributes, true) + "\n"
			html << inner_html
			html << "</div>\n"
			html << after_container
			return html.html_safe
		end
		
		# HTML attributes for the container
		def container_attributes
			{ class: 'grapple' }
		end

		# HTML to render before the container
		def before_container
			''
		end

		# HTML to render after the container
		def after_container
			''
		end

	protected

		# Helper output that renders outside the data table is held for #table, and the helper returns
		# nothing in its place. Pagination only moves when it has page links; the no-results row stays
		# in the data table.
		def invoke_helper(name, *arguments, &block)
			html = super
			if name == :toolbar || name == :infobar || (name == :pagination && page_links?(name))
				outside_table[name] << html
				return ''
			end
			html
		end

		def page_links?(name)
			component = @helper_instances[name]
			component.respond_to?(:page_links?) && component.page_links?
		end

		def outside_table
			@outside_table ||= { toolbar: '', infobar: '', pagination: '' }
		end

		def controls_html
			rows = outside_table[:toolbar] + outside_table[:infobar]
			return '' if rows.blank?
			"<div class=\"grapple-controls\">\n<table role=\"presentation\">\n<thead>\n#{rows}</thead>\n</table>\n</div>\n"
		end

		def pagination_html
			rows = outside_table[:pagination]
			return '' if rows.blank?
			"<div class=\"grapple-pagination\">\n<table role=\"presentation\">\n<tfoot>\n#{rows}</tfoot>\n</table>\n</div>\n"
		end

	end

end
