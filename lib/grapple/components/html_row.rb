module Grapple
	module Components
		class HtmlRow < HtmlComponent
			
			# TODO: should be able to take a block for the content
			def render(content, *options)
				(indent + template.content_tag(:tr, content.html_safe, *options) + "\n").html_safe
			end
			
		end
	end
end