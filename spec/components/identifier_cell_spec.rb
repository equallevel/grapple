require 'spec_helper'

describe 'identifier cell' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
		@builder = Grapple::DataGridBuilder.new(self, users_columns, users_records, {})
	end

	it "renders the identifier link after an empty 3-dot slot" do
		html = @builder.identifier_cell(label: 'REQ-1', url: '/requisitions/1')

		expect(html).to have_tag('td.grapple-identifier-cell > div.grapple-identifier') do
			with_tag('span.grapple-row-menu-spacer', with: { 'aria-hidden' => 'true' })
			with_tag('a.grapple-identifier__link', with: { href: '/requisitions/1' }, text: 'REQ-1')
		end
		expect(html).not_to have_tag('.grapple-row-select')
		expect(html).not_to have_tag('.grapple-identifier__attachment')
	end

	it "renders the checkbox, row menu, link and paperclip in order" do
		checkbox = '<input type="checkbox" id="select_1" class="approve-checkbox">'.html_safe
		html = @builder.identifier_cell(label: 'REQ-1', url: '/requisitions/1', select: checkbox,
			menu: [{ label: 'View', url: '/requisitions/1' }], attachments: true)

		expect(html).to have_tag('div.grapple-identifier') do
			with_tag('span.grapple-row-select > input#select_1.approve-checkbox')
			with_tag('div.grapple-row-menu')
			with_tag('span.grapple-identifier__attachment > svg', with: { 'aria-hidden' => 'true' })
			with_tag('span.grapple-identifier__attachment .grapple-visually-hidden', text: 'Has attachments')
		end
		expect(html).not_to have_tag('span.grapple-row-menu-spacer')
		order = ['grapple-row-select', 'grapple-row-menu', 'grapple-identifier__link', 'grapple-identifier__attachment']
		expect(order.map { |name| html.index(name) }).to eq(order.map { |name| html.index(name) }.sort)
	end

	it "renders a span when there is no url" do
		html = @builder.identifier_cell(label: 'REQ-1')

		expect(html).to have_tag('span.grapple-identifier__link', text: 'REQ-1')
		expect(html).not_to have_tag('a.grapple-identifier__link')
	end

end
