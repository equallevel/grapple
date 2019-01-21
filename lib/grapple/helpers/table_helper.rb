module Grapple
	module Helpers
		module TableHelper

			@@builder = Grapple::DataGridBuilder
			mattr_accessor :builder
		
			# Render a grapple table
			# @param columns [Enumerable]
			# @param records [Enumerable]
			# @option args :container [Boolean]
			#   If true the table will be rendered with a container div around it
			# @option args :html [Hash]
			#   HTML attributes for the `<table>` element
			# @option args :builder [Grapple::BaseTableBuilder]
			#   The table builder to use to render the table
			# @option args :params 
			def table_for(columns, records, *args, &block)
				options = args[0] || {}
				# Don't render the container for AJAX requests by default
				render_container = (options[:container].nil? ? !request.xhr? : options[:container]) rescue false
				table_html_attributes = options[:html] || {}
				options[:builder] = options[:builder] || @@builder
				request_params = options[:params] ? options[:params] : grapple_request_params
				builder = options[:builder].new(self, columns, records, request_params, options)
				output = capture(builder, &block)
				table_html = (builder.before_table + builder.table(output, table_html_attributes) + builder.after_table)
				if render_container
					builder.container(table_html)
				else
					table_html.html_safe
				end
			end
			
			def grapple_request_params
				# params might not be defined (being called from a mailer)
				# HACK: "defined? params" is returning method but when it gets called the method is not defined
				params()
			rescue
				request.params() rescue {}
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
