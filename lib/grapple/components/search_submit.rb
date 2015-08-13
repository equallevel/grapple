module Grapple
	module Components
		class SearchSubmit < HtmlComponent

			def render
				template.submit_tag(t(:filter))
			end

		end
	end
end
