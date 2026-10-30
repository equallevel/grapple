require 'spec_helper'

describe 'table layout' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
	end

	def render_table(records, html = {})
		builder = Grapple::DataGridBuilder.new(self, users_columns, records, {})
		content = builder.header
		content += builder.body { |user| concat("<td>#{user.login}</td>".html_safe) }
		content += builder.footer
		builder.table(content, html)
	end

	it "renders the toolbar, then the count, above the data table" do
		html = render_table(users_records, id: 'users')

		expect(html).to have_tag('div.grapple-controls > table > thead > tr.toolbar')
		expect(html).to have_tag('div.grapple-controls > table > thead > tr.infobar')
		expect(html.index('class="toolbar"')).to be < html.index('class="infobar"')
		expect(html.index('grapple-controls')).to be < html.index('grapple-scroll')
		expect(html.index('grapple-scroll')).to be < html.index('grapple-pagination')
	end

	it "keeps the column headings and rows in the data table" do
		html = render_table(users_records, id: 'users')

		expect(html).to have_tag('div.grapple-scroll > table#users > thead > tr.column-headers')
		expect(html).to have_tag('div.grapple-scroll > table#users > tbody > tr', count: 3)
		expect(html).not_to have_tag('div.grapple-scroll tr.toolbar')
		expect(html).not_to have_tag('div.grapple-scroll tr.infobar')
	end

	it "moves pagination below the data table when there are page links" do
		html = render_table(users_records)

		expect(html).to have_tag('div.grapple-pagination > table > tfoot > tr > td .pagination')
		expect(html).not_to have_tag('div.grapple-scroll tfoot tr')
	end

	it "keeps the no-results row in the data table" do
		html = render_table(User.where('id < 0').paginate(page: 1, per_page: 3))

		expect(html).to have_tag('div.grapple-scroll > table > tfoot > tr > td', text: "We're sorry. No results were found.")
		expect(html).not_to have_tag('div.grapple-pagination')
	end

	it "renders no pagination for a single page" do
		html = render_table(User.all.paginate(page: 1, per_page: 10))

		expect(html).not_to have_tag('div.grapple-pagination')
		expect(html).not_to have_tag('tfoot tr')
	end

	it "renders no pagination for array records" do
		builder = Grapple::DataGridBuilder.new(self, users_columns, User.all.to_a, {})
		html = builder.table(builder.footer)

		expect(html).not_to have_tag('div.grapple-pagination')
		expect(html).not_to have_tag('tfoot tr')
	end

	it "keeps custom footer rows in the data table" do
		builder = Grapple::DataGridBuilder.new(self, users_columns, users_records, {})
		footer = builder.footer { concat('<tr class="totals"><td>TOTAL</td></tr>'.html_safe) }
		html = builder.table(footer)

		expect(html).to have_tag('div.grapple-scroll > table > tfoot > tr.totals')
	end

	it "renders only the scroll box when there is no toolbar, count or pagination" do
		builder = Grapple::HtmlTableBuilder.new(self, users_columns, users_records, {})
		html = builder.table("<tbody><tr><td>TEST</td></tr></tbody>".html_safe)

		expect(html).to have_tag('div.grapple-scroll > table > tbody > tr > td', text: 'TEST')
		expect(html).not_to have_tag('div.grapple-controls')
		expect(html).not_to have_tag('div.grapple-pagination')
	end

end
