module Grapple
	module Components
		class HtmlComponent < BaseComponent

			setting :indent, "\t"

		protected

			include ERB::Util

			def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
				template.content_tag(name, content_or_options_with_block, options, escape, &block)
			end

			def table_url(options)
				if options[:sort] == params[:sort]
					options[:dir] = (params[:dir] == 'desc') ? 'asc' : 'desc'
				end
				# Convert ActionController::Parameters to a Hash
				p = if params.respond_to?(:to_unsafe_h)				
					params.to_unsafe_h
				else
					params.to_h
				end
				url_params = p.stringify_keys().merge(options.stringify_keys())
				if @builder.namespace
					tmp = {}
					url_params.each do |key, value|
						tmp[url_parameter(key)] = value
					end
					url_params = tmp
				end
				template.url_for url_params
			end

		end
	end
end
