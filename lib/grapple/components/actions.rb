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
						html_attr = action.dup
						html_attr.delete(:label)
						html_attr.delete(:url)
						html << template.send(link_to_helper, label, url, html_attr)
					end
				end			
				content_tag(:div, html.html_safe, class: 'actions')
			end

		end
	end
end
