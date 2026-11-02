require 'spec_helper'

describe 'row controls column' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
		@builder = Grapple::DataGridBuilder.new(self, users_columns, users_records, {}, row_controls: true)
	end

	it "leaves tables without row_controls as they are" do
		builder = Grapple::DataGridBuilder.new(self, users_columns, users_records, {})

		expect(builder.column_headings).to have_tag('th', count: users_columns.length)
		expect(builder.column_headings).not_to have_tag('th.grapple-row-controls-heading')
		expect(builder.table('')).not_to have_tag('table.grapple-has-row-controls')
	end

	it "adds a first heading with a visually hidden label" do
		html = @builder.column_headings

		expect(html).to have_tag('th', count: users_columns.length + 1)
		expect(html).to have_tag('th.grapple-row-controls-heading:first-child .grapple-visually-hidden', text: 'Row actions')
	end

	it "adds a <col> and marks the table" do
		expect(@builder.colgroup).to have_tag('col', count: users_columns.length + 1)
		expect(@builder.table('')).to have_tag('table.grapple-has-row-controls')
	end

	it "counts the column in the toolbar and no-rows colspans" do
		@builder.toolbar { concat('<div class="test">test</div>'.html_safe) }
		expect(@builder.table('')).to have_tag('tr.toolbar > th', with: { colspan: users_columns.length + 1 })

		builder = Grapple::DataGridBuilder.new(self, users_columns, [], {}, row_controls: true)
		html = builder.body(no_rows_html: 'No records') { |item| '' }
		expect(html).to have_tag('td', with: { colspan: users_columns.length + 1 }, text: 'No records')
	end

	it "does not change the caller's columns" do
		columns = users_columns.dup
		Grapple::DataGridBuilder.new(self, columns, users_records, {}, row_controls: true)

		expect(columns).to eq(users_columns)
	end

end
