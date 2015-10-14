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

		def self.container_attributes(template, options)
			return {
				:class => 'grapple'
			}
		end

		def self.before_container(template, options)
			''
		end

		def self.after_container(template, options)
			''
		end

	end

end
