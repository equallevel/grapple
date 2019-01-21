module Grapple
	module Components

		# Render links that apply to the table
		# @example
		#  <%
		#    actions = [
		#      { label: :new_user, url: new_user_path },
		#      { label: :export_users, url: export_users_path }
		#    ]
		#  %>
		#  <%= table_for(columns, @users) do |t| %>
		#    <%= t.header do %>
		#      <%= t.toolbar do %>
		#        <%= t.actions actions %>
		#      <% end %>
		#		   <%= t.column_headings %>
		#	   <% end %>
		#  <% end %>
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
