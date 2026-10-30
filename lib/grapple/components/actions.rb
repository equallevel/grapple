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
		#
		# Two or more actions render an "Actions" dropdown, which requires Bootstrap 5 JS.
		class Actions < HtmlComponent

			setting :link_to_helper, :link_to
			setting :dropdown_label, :actions

			def render(actions = [], &block)
				html = capture_block(&block)
				if actions.length > 1
					html << dropdown(actions)
					return content_tag(:div, html.html_safe, class: 'actions dropdown')
				end
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

		protected

			def dropdown(actions)
				toggle = content_tag(:button, t(dropdown_label), type: 'button', class: 'btn btn-primary dropdown-toggle',
					'data-bs-toggle' => 'dropdown', 'data-bs-offset' => '0,6', 'aria-expanded' => 'false')
				items = actions.collect { |action| content_tag(:li, menu_item(action)) }
				toggle + content_tag(:ul, items.join.html_safe, class: 'dropdown-menu')
			end

			# Button classes are dropped so the link renders as a menu item; other classes are kept
			# because they can be JavaScript hooks
			def menu_item(action)
				return action.html_safe if action.kind_of?(String)
				html_attr = action.except(:label, :url)
				classes = html_attr[:class].to_s.split.reject { |c| c == 'btn' || c.start_with?('btn-') }
				html_attr[:class] = (['dropdown-item'] + classes).join(' ')
				template.link_to(t(action[:label]), action[:url], html_attr)
			end

		end
	end
end
