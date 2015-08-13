require 'spec_helper'

describe 'Base Table Builder' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
	end


	it "should be correct" do
		builder = Grapple::DataGridBuilder.new(self, users_columns, users_records, {})

		html = builder.search_submit
		expect(html).to have_tag('input', with: { type: "submit"})

		html = builder.search_query_field
		expect(html).to have_tag('input', with: { type: "text"})

		html = builder.search_form
		expect(html).to have_tag('form')

		html = builder.actions
		expect(html).to have_tag('div.actions')

		html = builder.toolbar
		expect(html).to have_tag('tr.toolbar')

		html = builder.column_headings
		expect(html).to have_tag('tr.column-headers')

	end
	
end