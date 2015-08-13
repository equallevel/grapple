module Grapple
	module Components
		class Toolbar < HtmlComponent

			setting :components, []

			def render(*options, &block)
				options = options[0] || {}
				html = block_or_components(components, options, &block)
				builder.row "<th colspan=\"#{num_columns}\">#{html}</th>", :class => 'toolbar'
			end

		end
	end
end