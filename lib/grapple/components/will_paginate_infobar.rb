module Grapple
	module Components
		class WillPaginateInfobar < HtmlComponent

			def render
				if records.total_entries > 0
					start_range = records.offset + 1
					end_range = [records.offset + records.per_page, records.total_entries].min

					start_range = ActiveSupport::NumberHelper.number_to_delimited(start_range)
					end_range = ActiveSupport::NumberHelper.number_to_delimited(end_range)
					total = ActiveSupport::NumberHelper.number_to_delimited(records.total_entries)

					html = I18n.translate(:displaying_x_y_of_z_results, x: start_range, y: end_range, z: total)
				else
					html = I18n.translate(:zero_results)
				end

				builder.row "<th colspan=\"#{num_columns}\">#{html}</th>", class: 'infobar'
			end

		end
	end
end
