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
						label = t(action[:label])
						url = action[:url]
						html << template.send(link_to_helper, label, url, action)
					end
				end			
				content_tag(:div, html.html_safe, :class => 'actions')
			end

		end
	end
end
