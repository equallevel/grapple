module Grapple
	module Components
		class HtmlComponent < BaseComponent

			setting :indent, "\t"

			# Lucide icon contents (lucide-rails 0.7.4), inlined so grapple doesn't depend on an icon gem
			LUCIDE_ICONS = {
				ellipsis: '<circle cx="12" cy="12" r="1"></circle><circle cx="19" cy="12" r="1"></circle>' \
					'<circle cx="5" cy="12" r="1"></circle>',
				paperclip: '<path d="m16 6-8.414 8.586a2 2 0 0 0 2.829 2.829l8.414-8.586a4 4 0 1 0-5.657-5.657' \
					'l-8.379 8.551a6 6 0 1 0 8.485 8.485l8.379-8.551"></path>'
			}

		protected

			include ERB::Util

			def lucide_icon(name, size)
				(
					"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"#{size}\" height=\"#{size}\" viewBox=\"0 0 24 24\" " \
					"fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" " \
					"stroke-linejoin=\"round\" aria-hidden=\"true\" focusable=\"false\">#{LUCIDE_ICONS[name]}</svg>"
				).html_safe
			end

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
