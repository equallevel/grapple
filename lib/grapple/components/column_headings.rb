module Grapple
	module Components
		class ColumnHeadings < HtmlComponent

			setting :alignment_classes, { left: 'text-left', center: 'text-center', right: 'text-right' }
			setting :tooltip_class, 'table-tooltip'
			setting :row_class, 'column-headers'
			setting :row_controls_label, :row_actions

			def render(url_params = {})
				cols = columns.collect do |column|
					indent + column_header(column, url_params)
				end
				builder.row cols.join("\n"), :class => row_class
			end

			def column_header(column, additional_parameters = {})
				return row_controls_header(column) if column[:row_controls]

				cell_classes = []
				cell_classes << alignment_classes[(column[:align] || :left).to_sym]
				
				liner_classes = []
				liner_classes << tooltip_class if column[:title].present?

				label = t(column[:label] || '')
				
				if column[:sort]
					cell_classes << 'sortable'
					if column[:sort].to_s == params[:sort]
						liner_classes << (params[:dir] == 'desc' ? 'sort-desc' : 'sort-asc')
						cell_classes << 'sorted'
					end
					url = table_url(additional_parameters.merge({sort: column[:sort]}))
					content = template.link_to(label, url)
				else
					content = label
				end
				
				if column[:class]
					column[:class].split(" ").each{|c| cell_classes << c}
				end
				cell_classes << 'grapple-truncate' if truncate?(column)
				
				cell_classes = ' class="' + cell_classes.join(' ') + '"'
				title = column[:title] ? " title=\"#{h(column[:title])}\"" : ''
				liner_classes = liner_classes.length ? " class=\"#{liner_classes.join(" ")}\"" : ''
				style = width_style(column)
				style = style.present? ? " style=\"#{style}\"" : ''

				"<th#{cell_classes}#{style}><div#{title}#{liner_classes}>#{h content}</div></th>".html_safe
			end

		protected

			def row_controls_header(column)
				label = content_tag(:span, t(row_controls_label), class: 'grapple-visually-hidden')
				"<th class=\"#{column[:class]}\">#{label}</th>".html_safe
			end

			# Values truncate after three lines where the column can't grow past a set width
			def truncate?(column)
				builder.strict_widths? && (column[:width] || column[:max_width]).present?
			end

			# Content widths for grapple.css; width is fixed, max_width caps a variable column
			def width_style(column)
				return nil unless builder.strict_widths?
				width = column[:width] || column[:max_width]
				min = column[:width] || column[:min_width]
				styles = []
				styles << "--grapple-col-width: #{width.to_i}px" if width.present?
				styles << "--grapple-col-min: #{min.to_i}px" if min.present?
				styles.join('; ')
			end

		end
	end
end
