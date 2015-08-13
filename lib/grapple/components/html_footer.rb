module Grapple
	module Components
		class HtmlFooter < HtmlComponent

			setting :components, []

			def render(*options, &block)
				html = block_or_components(components, options[0] || {}, &block)
				"<tfoot>\n#{html}</tfoot>\n".html_safe
			end

		end
	end
end