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
		class KaminariPagination < HtmlComponent

			setting :no_results_message, :no_search_results
			setting :renderer, nil

			def render(paginate_parameters = {})
				td_class = ""
				if records.instance_of?(Array)
					html = '&nbsp;'
				elsif !params[:query].blank? and records.empty?
					html = h(t(no_results_message))
					td_class = "class='text-left'"
				else
					begin
						# paginate helper will throw an error if without_count is being used
						html = template.paginate(records)
					rescue Exception => e
						html = template.link_to_prev_page(records, "Previous Page") || ""
						html += " " if html
						html += template.link_to_next_page(records, "Next Page")
					end
				end

				builder.row "<td colspan=\"#{num_columns}\" #{td_class}>#{html}</td>"
			end
		
		end
	end
end
