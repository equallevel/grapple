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
				template.url_for params.stringify_keys().merge(options.stringify_keys())
			end

		end
	end
end
