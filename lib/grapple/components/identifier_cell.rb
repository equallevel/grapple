module Grapple
	module Components

		# First two cells of a row: the controls cell (an optional checkbox and the 3-dot row menu), then
		# the identifier, an optional caller-supplied suffix (an icon, say) and an optional paperclip.
		# The table needs `row_controls: true`.
		# @example
		#   <%= t.identifier_cell label: requisition.number, url: requisition_path(requisition),
		#     select: check_box_tag('ids[]', requisition.id), menu: menu_items, attachments: true %>
		class IdentifierCell < HtmlComponent

			setting :attachments_label, :has_attachments

			def render(options = {})
				raise ArgumentError.new('identifier_cell needs table_for(..., row_controls: true)') unless builder.row_controls?
				controls = ''
				controls << content_tag(:span, options[:select], class: 'grapple-row-select') if options[:select].present?
				controls << row_menu(options[:menu])
				html = ''
				html << identifier(options.fetch(:label), options[:url], options[:suffix])
				html << attachment if options[:attachments]
				content_tag(:td, content_tag(:div, controls.html_safe, class: 'grapple-row-controls__items'), class: 'grapple-row-controls') +
					content_tag(:td, content_tag(:div, html.html_safe, class: 'grapple-identifier'), class: 'grapple-identifier-cell')
			end

		protected

			# Rows without actions keep an empty slot so identifiers stay aligned
			def row_menu(items)
				return builder.row_menu(items) if items.present?
				content_tag(:span, '', class: 'grapple-row-menu-spacer', 'aria-hidden' => 'true')
			end

			# A suffix sits right after the text, so the two share a wrapper with their own gap
			def identifier(label, url, suffix = nil)
				html = if url.present?
					template.link_to(label, url, class: 'grapple-identifier__link')
				else
					content_tag(:span, label, class: 'grapple-identifier__link')
				end
				return html if suffix.blank?
				content_tag(:span, html + content_tag(:span, suffix, class: 'grapple-identifier__suffix'),
					class: 'grapple-identifier__label')
			end

			def attachment
				text = content_tag(:span, t(attachments_label), class: 'grapple-visually-hidden')
				content_tag(:span, lucide_icon(:paperclip, 16) + text, class: 'grapple-identifier__attachment')
			end

		end
	end
end
