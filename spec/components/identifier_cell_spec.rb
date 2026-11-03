require 'spec_helper'

describe 'identifier cell' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
		@builder = Grapple::DataGridBuilder.new(self, users_columns, users_records, {}, row_controls: true)
	end

	it "renders an empty 3-dot slot in the controls cell, then the identifier cell" do
		html = @builder.identifier_cell(label: 'REQ-1', url: '/requisitions/1')

		expect(html).to have_tag('td.grapple-row-controls > div.grapple-row-controls__items') do
			with_tag('span.grapple-row-menu-spacer', with: { 'aria-hidden' => 'true' })
		end
		expect(html).to have_tag('td.grapple-identifier-cell > div.grapple-identifier') do
			with_tag('a.grapple-identifier__link', with: { href: '/requisitions/1' }, text: 'REQ-1')
		end
		expect(html).not_to have_tag('.grapple-row-select')
		expect(html).not_to have_tag('.grapple-identifier__attachment')
		expect(html.index('grapple-row-controls')).to be < html.index('grapple-identifier-cell')
	end

	it "puts the checkbox and row menu in the controls cell and the paperclip after the link" do
		checkbox = '<input type="checkbox" id="select_1" class="approve-checkbox">'.html_safe
		html = @builder.identifier_cell(label: 'REQ-1', url: '/requisitions/1', select: checkbox,
			menu: [{ label: 'View', url: '/requisitions/1' }], attachments: true)

		expect(html).to have_tag('td.grapple-row-controls > div.grapple-row-controls__items') do
			with_tag('span.grapple-row-select > input#select_1.approve-checkbox')
			with_tag('div.grapple-row-menu')
		end
		expect(html).to have_tag('td.grapple-identifier-cell > div.grapple-identifier') do
			with_tag('a.grapple-identifier__link')
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

	it "draws a 16px paperclip" do
		html = @builder.identifier_cell(label: 'REQ-1', url: '/requisitions/1', attachments: true)

		expect(html).to have_tag('span.grapple-identifier__attachment > svg', with: { width: '16', height: '16' })
	end

	it "needs the table's controls column" do
		builder = Grapple::DataGridBuilder.new(self, users_columns, users_records, {})

		expect { builder.identifier_cell(label: 'REQ-1') }.to raise_error(ArgumentError, /row_controls/)
	end

end
