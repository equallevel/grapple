module Grapple
	module Components
		class WillPaginateInfobar < HtmlComponent

			setting :message, "Displaying %s - %s of %s results"
			setting :no_results_message, "0 results"

			def render
				if records.total_entries > 0
					start_range = records.offset + 1
					end_range = [records.offset + records.per_page, records.total_entries].min

					start_range = ActiveSupport::NumberHelper.number_to_delimited(start_range)
					end_range = ActiveSupport::NumberHelper.number_to_delimited(end_range)
					total = ActiveSupport::NumberHelper.number_to_delimited(records.total_entries)

					html = sprintf(message, start_range, end_range, total)
				else
					html = no_results_message
				end

				builder.row "<th colspan=\"#{num_columns}\">#{html}</th>", :class => 'infobar'
			end

		end
	end
end
