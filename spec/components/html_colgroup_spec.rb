require 'spec_helper'

describe 'html_colgroup' do
	include GrappleSpecHelper

	columns = [
		{ label: '' },
		{ label: 'first name', sort: 'LOWER(firstname)', width: 140 },
		{ label: 'last name', sort: 'LOWER(lastname)', width: 140 },
		{ label: 'username', sort: 'LOWER(login)', width: 150 },
		{ label: 'email', sort: 'LOWER(email)', width: 300 },
		{ label: 'Created At', sort: 'created_at', width: 175 }
	]
	
	before do
		@output_buffer = ''
		mock_everything
	end
	
	it "should be valid" do
		records = User.all.paginate({ page: 1, per_page: 3 })
		builder = Grapple::HtmlTableBuilder.new(self, columns, records, {})
		html = builder.colgroup()

		#puts html

		expect(html).to have_tag('colgroup') do
			with_tag('col', count: columns.length)

			columns.each do |column|
				with_tag('col', with: {width: column[:width]}) if column[:width].present?
			end

		end
		
	end

end