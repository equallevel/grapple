require 'spec_helper'

describe 'row menu' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
		@builder = Grapple::DataGridBuilder.new(self, users_columns, users_records, {})
	end

	it "renders nothing without items" do
		expect(@builder.row_menu([])).to be_blank
	end

	it "renders a 3-dot toggle and a menu" do
		items = [
			{ label: 'View', url: '/users/1' },
			{ label: 'Delete', url: '/users/1', destructive: true, id: 'delete-user-1', class: 'js-delete',
				data: { method: 'delete', confirm: 'Sure?' } }
		]
		html = @builder.row_menu(items)

		expect(html).to have_tag('div.grapple-row-menu.dropdown') do
			with_tag('button.grapple-row-menu__toggle', with: {
				type: 'button', 'data-bs-toggle' => 'dropdown', 'aria-expanded' => 'false', 'aria-label' => 'Row actions',
				'data-bs-offset' => '0,4'
			}) do
				with_tag('svg', with: { 'aria-hidden' => 'true' })
			end
			with_tag('ul.dropdown-menu > li > a.dropdown-item', count: 2)
			with_tag('a.dropdown-item', with: { href: '/users/1' }, text: 'View')
			with_tag('a.dropdown-item.grapple-menu-item--destructive.js-delete#delete-user-1',
				with: { 'data-method' => 'delete', 'data-confirm' => 'Sure?' }, text: 'Delete')
		end
		expect(html).not_to have_tag('a[destructive]')
		expect(html).not_to have_tag('a.grapple-menu-item--destructive', text: 'View')
	end

	it "escapes labels" do
		html = @builder.row_menu([{ label: '<b>View</b>', url: '/users/1' }])

		expect(html).not_to have_tag('a b')
	end

end
