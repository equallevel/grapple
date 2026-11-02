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

		# Pagination with page links renders below the data table
		expect(html).to have_tag('tfoot')
		expect(html).not_to have_tag('tfoot tr')
		expect(builder.table('')).to have_tag('div.grapple-pagination tfoot tr', count: 1)

		#puts html
	end

end