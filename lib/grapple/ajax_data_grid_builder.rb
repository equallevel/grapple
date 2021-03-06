module Grapple
	class AjaxDataGridBuilder < DataGridBuilder

		CONTAINER_CLASSES = 'grapple grapple-ajax grapple-ajax-loading'

		@@next_id = 1000

		def container_attributes	
			@@next_id += 1
			@options[:id] ||= "grapple_ajax_table_#{@@next_id}"
			css = CONTAINER_CLASSES
			css += " #{@options[:container_class]}" unless @options[:container_class].nil?

			data = {
				"grapple-ajax-url" => @options[:url] || template.url_for(action: 'table'),
				# History is disabled by default, override container_attributes
				# in an initializer to enable it by default
				"grapple-ajax-history" => @options[:history] == true ? '1' : '0'
			}
			
			# The namespace allows the query parameters to be namespaced so 
			# multiple tables can exist on the same page
			data["grapple-ajax-namespace"] = @options[:namespace] unless @options[:namespace].nil?
			
			return {
				:id => @options[:id],
				:class => css,
				:data => data
			}
		end

		def after_table
			style = 'background-image: url(' + template.image_path("grapple/loading-bar.gif") + ')'
			template.content_tag :div, '', class: 'loading-overlay', style: style
		end

		def after_container
			selector = '#' + @options[:id]
			js = "$(#{selector.to_json}).grapple();"
			return template.javascript_tag(js)
		end

	end
end
