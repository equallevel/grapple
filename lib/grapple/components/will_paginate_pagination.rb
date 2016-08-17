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
				if records.instance_of?(Array)
					html = '&nbsp;'
				elsif !params[:query].blank? and records.empty?
					html = h(t(no_results_message))
				else
					paginate_parameters[:param_name] = url_parameter(:page) if builder.namespace
					html = template.will_paginate(records, { renderer: renderer }.compact.merge(paginate_parameters)) || '&nbsp;'
				end

				builder.row "<td colspan=\"#{num_columns}\">#{html}</td>"
			end
		
		end
	end
end
