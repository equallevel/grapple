module Grapple
	module Components
		class HtmlColgroup < HtmlComponent

			def render
				# Strict widths are set on the headings, since <col> can't take a min-width
				cols = columns.collect do |col|
					indent + (col[:width].nil? || builder.strict_widths? ? "<col>" : "<col width=\"#{col[:width]}\">")
				end
				"<colgroup>\n#{cols.join("\n")}\n</colgroup>\n".html_safe
			end

		end
	end
end
