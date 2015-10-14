module Grapple
	module Components
		class HtmlColgroup < HtmlComponent

			def render
				cols = columns.collect do |col|
					indent + (col[:width].nil? ? "<col>" : "<col width=\"#{col[:width]}\">")
				end
				"<colgroup>\n#{cols.join("\n")}\n</colgroup>\n".html_safe
			end

		end
	end
end
