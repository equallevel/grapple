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

			# Small screens get first, current and last pages only. CSS shows one list per breakpoint;
			# the compact list is left out when it would match the full one.
			def page_lists(full_list, options)
				compact_list = template.will_paginate(records, options.merge(inner_window: 0, outer_window: 0))
				return "<div class=\"grapple-pagination__pages\">#{full_list}</div>" if compact_list == full_list
				"<div class=\"grapple-pagination__pages grapple-pagination__pages--full\">#{full_list}</div>" \
					"<div class=\"grapple-pagination__pages grapple-pagination__pages--compact\">#{compact_list}</div>"
			end
		
		end
	end
end
