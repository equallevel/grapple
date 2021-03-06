module Grapple
	module Components
		class HtmlBody < HtmlComponent

			# If not false, each row will be wrapped in a <tr> tag
			# if false, the <tr> tag needs to be added in the block
			# if the value is a proc, it will be called for each row
			# and the returned value will be passed as the options to 
			# the tr tag
			setting :tr, true
			
			# An HTML fragment to render in the body of the table if there are no rows
			setting :no_rows_html, nil

			def render(*options, &block)
				options = options[0] || {}
				
				wrap_row = if options[:tr].nil?
					self.tr
				elsif options[:tr] === false
					false
				else
					options[:tr]
				end
				
				args = {}
				if records.empty? && !options[:no_rows_html].nil?
					html = ["<tr><td colspan=\"#{columns.length}\">#{options[:no_rows_html]}</td></tr>"]
				else
					html = records.collect do |data|
						if wrap_row		
							args = wrap_row.call(template) if wrap_row.is_a?(Proc)
							builder.row(capture_block { block.call(data) }, args)
						else
							indent + capture_block { block.call(data) }
						end
					end
				end
				"<tbody>\n#{html.join("\n")}\n</tbody>\n".html_safe
			end
			
		end
	end
end