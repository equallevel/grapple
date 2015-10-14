module Grapple
	module Components
		class HtmlCaption < HtmlComponent

			def render(*options, &block)
				html = capture_block(options[0] || '', &block)
				"<caption>\n#{html}</caption>\n".html_safe
			end

		end
	end
end
