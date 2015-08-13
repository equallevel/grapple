require 'spec_helper'

describe 'toolbar' do
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
		builder = Grapple::DataGridBuilder.new(self, columns, records, {})
		#puts builder.methods.inspect

		html = builder.toolbar do 
			concat('<div class="test">test</div>'.html_safe)
		end

		expect(html).to have_tag('tr', with: { class: 'toolbar' }) do
			with_tag('th', with: { colspan: columns.length }) do
				with_tag('div', with: { class: 'test' })
			end
		end
		
		#puts html
	end

end