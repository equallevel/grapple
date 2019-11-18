require 'spec_helper'

describe 'Base Table Builder' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
	end

	it "container_attributes should be correct" do
		builder = Grapple::HtmlTableBuilder.new(self, users_columns, users_records, {}, id: 'my_table')
		attr = builder.container_attributes()
		expect(attr[:class]).to include("grapple")
	end

	it "table should be correct" do
		builder = Grapple::HtmlTableBuilder.new(self, users_columns, users_records, {})

		html = builder.table("<tr><td>TEST</td></tr>".html_safe)

		expect(html).to have_tag('table') do
			with_tag("tr", count: 1) do 
				with_tag("td", count: 1) do
					with_text("TEST")
				end
			end
		end
	end
	
end
