require 'spec_helper'

describe 'actions' do
	include GrappleSpecHelper


	
	before do
		@output_buffer = ''
		mock_everything
	end
	
	it "should be valid" do
		actions = [
			{ label: "New User", url: "/test" },
			{ label: "Export Users", url: url_for({controller: 'users', action: 'new'}) }
		]
		builder = Grapple::DataGridBuilder.new(self, [], [], {})
		html = builder.actions(actions.clone)

		#puts html

		expect(html).to have_tag('div.actions') do
			with_tag("a", count: actions.length)
			actions.each do |action|
				with_tag("a", with: {href: action[:url]}) do
					with_text(action[:label])
				end
			end
		end
	end

	it "renders an empty container when there are no actions" do
		builder = Grapple::DataGridBuilder.new(self, [], [], {})

		expect(builder.actions([])).to eq('<div class="actions"></div>')
	end

	it "renders a single action as a link" do
		builder = Grapple::DataGridBuilder.new(self, [], [], {})
		html = builder.actions([{ label: 'New User', url: '/new', class: 'btn btn-primary' }])

		expect(html).to have_tag('div.actions > a.btn.btn-primary', with: { href: '/new' }, text: 'New User')
		expect(html).not_to have_tag('.dropdown')
	end

	it "renders two or more actions as an Actions dropdown" do
		actions = [
			{ label: 'New User', url: '/new', id: 'new-user', class: 'btn-sm btn-secondary mass-approval',
				data: { export_name: 'users' } },
			{ label: 'Export', url: '/export', target: '_blank' }
		]
		builder = Grapple::DataGridBuilder.new(self, [], [], {})
		html = builder.actions(actions)

		expect(html).to have_tag('div.actions.dropdown') do
			with_tag('button.btn.btn-primary.dropdown-toggle', with: {
				type: 'button', 'data-bs-toggle' => 'dropdown', 'aria-expanded' => 'false', 'data-bs-offset' => '0,6'
			}, text: 'Actions')
			with_tag('ul.dropdown-menu > li > a.dropdown-item', count: 2)
			with_tag('a.dropdown-item.mass-approval#new-user', with: { href: '/new', 'data-export-name' => 'users' },
				text: 'New User')
			with_tag('a.dropdown-item', with: { href: '/export', target: '_blank' }, text: 'Export')
		end
		expect(html).not_to have_tag('a.btn-sm')
		expect(html).not_to have_tag('a.btn-secondary')
	end

	it "renders string actions inside menu items" do
		actions = ['<a href="/a" class="custom">A</a>'.html_safe, { label: 'B', url: '/b' }]
		builder = Grapple::DataGridBuilder.new(self, [], [], {})

		expect(builder.actions(actions)).to have_tag('ul.dropdown-menu > li > a.custom', text: 'A')
	end

	it "uses the dropdown_label setting" do
		builder = Grapple::DataGridBuilder.new(self, [], [], {})
		component = Grapple::Components::Actions.new([], [], self, {}, builder, dropdown_label: 'Options')
		html = component.render([{ label: 'A', url: '/a' }, { label: 'B', url: '/b' }])

		expect(html).to have_tag('button.dropdown-toggle', text: 'Options')
	end

end