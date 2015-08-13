module Grapple
	module Helpers
		module TableHelper

			@@builder = Grapple::DataGridBuilder
			mattr_accessor :builder

			def grapple_container(*args, &block)
				options = args[0] || {}
				builder_class = options[:builder] || @@builder
				container_attr = builder_class.container_attributes(self, options)
				html = ''
				html << builder_class.before_container(self, options)
				html << tag('div', container_attr, false) + "\n"
				html << capture(&block)
				html << "</div>\n"
				html << builder_class.after_container(self, options)
				return html.html_safe
			end
		
			def table_for(columns, records, *args, &block)
				options = args[0] || {}
				builder_class = options[:builder] || @@builder
				builder = builder_class.new(self, columns, records, params, options)
				output = capture(builder, &block)
				(builder.before_table + builder.table(output) + builder.after_table).html_safe
			end
		
		end
	end
end
