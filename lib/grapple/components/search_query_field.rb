module Grapple
	module Components
		class SearchQueryField < HtmlComponent
			
			setting :search_query_param, 'query'
			setting :search_query_field_class, 'search-query'
			
			def render(*options, &block)
				template.text_field_tag(search_query_param.to_s, params[search_query_param.to_sym], { :class => search_query_field_class })
			end

		end
	end
end
