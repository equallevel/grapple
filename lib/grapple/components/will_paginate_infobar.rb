module Grapple
	module Components
		class WillPaginateInfobar < HtmlComponent

			setting :message, "Displaying %d - %d of %d items"
			setting :no_results_message, "0 items"

			def render
				if records.total_entries > 0
					start_range = records.offset + 1
					end_range = [records.offset + records.per_page, records.total_entries].min
					html = sprintf(message, start_range, end_range, records.total_entries)
				else
					html = no_results_message
				end

				builder.row "<th colspan=\"#{num_columns}\">#{html}</th>", :class => 'infobar'
			end

		end
	end
end
