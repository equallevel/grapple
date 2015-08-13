require 'spec_helper'

describe 'html footer' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
	end
	
	it "should be valid" do
		records = User.all.paginate({ page: 1, per_page: 3 })
		builder = Grapple::DataGridBuilder.new(self, users_columns, records, {})

		html = builder.footer do |item|
			concat(("<tr><td>TEST</td></tr>").html_safe)
		end

		#puts html

		expect(html).to have_tag('tfoot') do
			with_tag('tr', count: 1) do
				with_tag('td', count: 1) do
					with_text("TEST")
				end
			end
		end
		
		html = builder.footer

		expect(html).to have_tag('tfoot') do
			with_tag('tr', count: 1) 
		end

		#puts html
	end

end