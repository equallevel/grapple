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

			def render(paginate_parameters = {})
				td_class = ""

				if records.instance_of?(Array)
					html = '&nbsp;'
				elsif records.empty?
					html = h(t(no_results_message))
					td_class = "class='no-results-message text-left'"
				else
					paginate_parameters[:param_name] = url_parameter(:page) if builder.namespace
					options = { renderer: renderer }.select { |_, value| !value.nil? }.merge(paginate_parameters)
					html = template.will_paginate(records, options) || '&nbsp;'
				end

				builder.row "<td colspan=\"#{num_columns}\" #{td_class}>#{html}</td>"
			end
		
		end
	end
end
