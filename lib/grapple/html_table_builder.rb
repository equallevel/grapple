module Grapple

	class HtmlTableBuilder < BaseTableBuilder

		# Standard HTML table elements
		helper :caption, Grapple::Components::HtmlCaption
		helper :row, Grapple::Components::HtmlRow
		helper :colgroup, Grapple::Components::HtmlColgroup
		helper :header, Grapple::Components::HtmlHeader
		helper :body, Grapple::Components::HtmlBody
		helper :footer, Grapple::Components::HtmlFooter

		def table(content, attributes = {})
			"#{template.content_tag('table', content, attributes)}\n".html_safe
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

	end

end
