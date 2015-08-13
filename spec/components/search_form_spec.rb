require 'spec_helper'

describe 'search form' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
	end
	
	it "should be valid" do
		records = User.all.paginate({ page: 1, per_page: 3 })
		builder = Grapple::DataGridBuilder.new(self, users_columns, records, {})
		
		html = builder.search_form()

		puts html

		expect(html).to have_tag('form.search-form', with: {method: "post"}) do
			with_tag('input', with: {type: "hidden", name: "page"})
			with_tag('input', with: {type: "hidden", name: "utf8"})

			with_tag('input', with: {name: "query", type: "text", id: 'query', class: 'search-query'})
			with_tag('input', with: {type: "submit"})
		end

	end

end