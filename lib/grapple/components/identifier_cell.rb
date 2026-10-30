module Grapple
	module Components

		# First cell of a row: an optional checkbox, the 3-dot row menu, the identifier and an optional paperclip
		# @example
		#   <%= t.identifier_cell label: requisition.number, url: requisition_path(requisition),
		#     select: check_box_tag('ids[]', requisition.id), menu: menu_items, attachments: true %>
		class IdentifierCell < HtmlComponent

			setting :attachments_label, :has_attachments

			def render(options = {})
				html = ''
				html << content_tag(:span, options[:select], class: 'grapple-row-select') if options[:select].present?
				html << row_menu(options[:menu])
				html << identifier(options.fetch(:label), options[:url])
				html << attachment if options[:attachments]
				content_tag(:td, content_tag(:div, html.html_safe, class: 'grapple-identifier'), class: 'grapple-identifier-cell')
			end

		protected

			# Rows without actions keep an empty slot so identifiers stay aligned
			def row_menu(items)
				return builder.row_menu(items) if items.present?
				content_tag(:span, '', class: 'grapple-row-menu-spacer', 'aria-hidden' => 'true')
			end

			def identifier(label, url)
				return template.link_to(label, url, class: 'grapple-identifier__link') if url.present?
				content_tag(:span, label, class: 'grapple-identifier__link')
			end

			def attachment
				text = content_tag(:span, t(attachments_label), class: 'grapple-visually-hidden')
				content_tag(:span, lucide_icon(:paperclip, 14) + text, class: 'grapple-identifier__attachment')
			end

		end
	end
end
