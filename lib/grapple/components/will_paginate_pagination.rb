module Grapple
	module Components
		# Generates paging links using will_paginate.
		#
		# @example 
		#   <%= table_for(columns, Post.paginate(page: 2)) do |t| %>
		#     <%= t.footer do %>
		#       <%= t.pagination %>
		#     <% end %>
		#   <% end %>
		#
		class WillPaginatePagination < HtmlComponent

			setting :no_results_message, :no_search_results
			setting :renderer, nil
			setting :inner_window, 2
			setting :outer_window, 1

			# Renders nothing when there is only one page
			def render(paginate_parameters = {})
				td_class = ""
				@page_links = false

				if records.instance_of?(Array)
					return ''
				elsif records.empty?
					html = h(t(no_results_message))
					td_class = "class='no-results-message text-left'"
				else
					paginate_parameters[:param_name] = url_parameter(:page) if builder.namespace
					options = { renderer: renderer, inner_window: inner_window, outer_window: outer_window }
					options = options.select { |_, value| !value.nil? }.merge(paginate_parameters)
					full_list = template.will_paginate(records, options)
					return '' if full_list.blank?
					@page_links = true
					html = page_lists(full_list, options)
				end

				builder.row "<td colspan=\"#{num_columns}\" #{td_class}>#{html}</td>"
			end

			# True when the last render had page links
			def page_links?
				@page_links == true
			end

		protected

			# Small screens get 5 page slots (first, current, last and gaps). CSS shows one list per
			# breakpoint; the compact list is left out when it would match the full one.
			def page_lists(full_list, options)
				single_list = "<div class=\"grapple-pagination__pages\">#{full_list}</div>"
				return single_list if records.total_pages <= 5

				compact_list = template.will_paginate(records, options.merge(compact_window_options))
				return single_list if compact_list == full_list
				"<div class=\"grapple-pagination__pages grapple-pagination__pages--full\">#{full_list}</div>" \
					"<div class=\"grapple-pagination__pages grapple-pagination__pages--compact\">#{compact_list}</div>"
			end

			# will_paginate shifts the inner window inward at the bounds, so a 1-page window on the first
			# or last two pages fills 5 slots (1 2 3 … N, 1 … N-2 N-1 N), like 1 … c … N in the middle
			def compact_window_options
				page = records.current_page
				edge = page <= 2 || page >= records.total_pages - 1
				{ inner_window: edge ? 1 : 0, outer_window: 0 }
			end
		
		end
	end
end
