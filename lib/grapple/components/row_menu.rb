module Grapple
	module Components

		# 3-dot menu of row actions, which requires Bootstrap 5 JS
		# @example
		#   <%= t.row_menu [
		#     { label: :view, url: user_path(user) },
		#     { label: :delete, url: user_path(user), destructive: true, data: { method: :delete } }
		#   ] %>
		class RowMenu < HtmlComponent

			setting :toggle_label, :row_actions

			def render(items = [])
				return '' if items.blank?
				toggle = content_tag(:button, lucide_icon(:ellipsis, 16), type: 'button', class: 'grapple-row-menu__toggle',
					'data-bs-toggle' => 'dropdown', 'data-bs-offset' => '0,4', 'aria-expanded' => 'false',
					'aria-label' => t(toggle_label))
				menu = content_tag(:ul, items.collect { |item| menu_item(item) }.join.html_safe, class: 'dropdown-menu')
				content_tag(:div, toggle + menu, class: 'grapple-row-menu dropdown')
			end

		protected

			# Every key other than label, url and destructive is passed to the link
			def menu_item(item)
				html_attr = item.except(:label, :url, :destructive)
				classes = ['dropdown-item', html_attr[:class]]
				classes << 'grapple-menu-item--destructive' if item[:destructive]
				html_attr[:class] = classes.compact.join(' ')
				content_tag(:li, template.link_to(t(item[:label]), item[:url], html_attr))
			end

		end
	end
end
