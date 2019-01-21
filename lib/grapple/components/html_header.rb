module Grapple
	module Components

		# thead element for tables
		class HtmlHeader < HtmlComponent
			
			setting :components, []
			
			def render(*options, &block)
				html = block_or_components(components, options[0] || {}, &block)
				"<thead>\n#{html}</thead>\n".html_safe
			end
			
		end
		
	end
end