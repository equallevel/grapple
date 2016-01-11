module Grapple
	module Helpers
		module TableHelper

			@@builder = Grapple::DataGridBuilder
			mattr_accessor :builder

			def table_for(columns, records, *args, &block)
				options = args[0] || {}
				table_html_attributes = options[:html] || {}
				builder_class = options[:builder] || @@builder
				# params might not be defined (being called from a mailer)
				# HACK: "defined? params" is returning method but when it gets called the method is not defined
				request_params = params() rescue {}
				builder = builder_class.new(self, columns, records, request_params, options)
				output = capture(builder, &block)
				(builder.before_table + builder.table(output, table_html_attributes) + builder.after_table).html_safe
			end

			def grapple_container(*args, &block)
				options = args[0] || {}
				builder_class = options[:builder] || @@builder
				container_attr = builder_class.container_attributes(self, options)
				html = ''
				html << builder_class.before_container(self, options)
				html << tag('div', container_attr, true) + "\n"
				html << capture(&block)
				html << "</div>\n"
				html << builder_class.after_container(self, options)
				return html.html_safe
			end

		end
	end
end
