module Grapple
	module Components
		class SearchSubmit < HtmlComponent

			setting :label, 'Filter'
		
			def render
				template.submit_tag(t(label))
			end

		end
	end
end
