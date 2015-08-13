module Grapple
	module Components
		class Actions < HtmlComponent

			setting :link_to_helper, :link_to

			def render(actions = [], &block)
				html = capture_block(&block)
				actions.each do |action|
					if action.kind_of?(String)
						html << action
					else
						# TODO: why are we deleting the label and url?
						label = action.delete(:label)
						url = action.delete(:url)
						html << template.send(link_to_helper, label, url, action)
					end
				end			
				content_tag(:div, html.html_safe, :class => 'actions')
			end

		end
	end
end
