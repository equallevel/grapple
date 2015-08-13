require 'spec_helper'

describe 'actions' do
	include GrappleSpecHelper


	
	before do
		@output_buffer = ''
		mock_everything
	end
	
	it "should be valid" do
		actions = [
			{ label: "New User", url: "/test" },
			{ label: "Export Users", url: url_for({controller: 'users', action: 'new'}) }
		]
		builder = Grapple::DataGridBuilder.new(self, [], [], {})
		html = builder.actions(actions.clone)

		#puts html

		expect(html).to have_tag('div.actions') do
			with_tag("a", count: actions.length)
			actions.each do |action|
				with_tag("a", with: {href: action[:url]}) do
					with_text(action[:label])
				end
			end
		end
	end

end