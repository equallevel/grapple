module Grapple
	module Components
		class KaminariInfobar < HtmlComponent

			setting :message, "Displaying %s - %s of %s results"
			setting :estimate_message, "Displaying %s - %s of about %s results"
			setting :no_results_message, "0 results"

			def render
				estimate = false
				begin
					# total_count will throw an error if without_count is being used
					total_count = records.total_count
				rescue Exception => e
					estimate = true
					total_count = ActiveRecord::Base.connection.execute(
						"SELECT reltuples AS approximate_row_count FROM pg_class WHERE relname = '#{records.table_name}'"
					).first["approximate_row_count"].to_i
				end
				
				if total_count > 0
					offset = (records.current_page - 1) * records.current_per_page
					start_range = offset + 1
					end_range = [offset + records.current_per_page, total_count].min

					start_range = ActiveSupport::NumberHelper.number_to_delimited(start_range)
					end_range = ActiveSupport::NumberHelper.number_to_delimited(end_range)
					total = ActiveSupport::NumberHelper.number_to_delimited(total_count)

					html = sprintf((estimate ? estimate_message : message), start_range, end_range, total)
				else
					html = no_results_message
				end

				builder.row "<th colspan=\"#{num_columns}\">#{html}</th>", :class => 'infobar'
			end

		end
	end
end
