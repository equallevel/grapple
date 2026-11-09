require 'spec_helper'

describe 'will_paginate' do
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

		records = User.where('id < 0').paginate({ page: 1, per_page: 3 })
		builder = Grapple::DataGridBuilder.new(self, columns, records, {:query => 'test'})	
	end

	# Page 12 of 30, one record per page
	def middle_page_records
		WillPaginate::Collection.create(12, 1, 30) { |pager| pager.replace([User.first]) }
	end

	def render_pagination(records, *args)
		builder = Grapple::DataGridBuilder.new(self, users_columns, records, {})
		builder.pagination(*args)
		builder.table('')
	end

	it "uses a 2-page inner window and a 1-page outer window" do
		html = render_pagination(middle_page_records)

		expect(html).to have_tag('.grapple-pagination__pages--full') do
			['1', '2', '10', '11', '13', '14', '29', '30'].each { |page| with_tag('a', text: page) }
			without_tag('a', text: '9')
			without_tag('a', text: '15')
		end
	end

	it "renders a compact list of the first, current and last pages" do
		html = render_pagination(middle_page_records)

		expect(html).to have_tag('.grapple-pagination__pages--compact') do
			with_tag('a', text: '1')
			with_tag('.current', text: '12')
			with_tag('a', text: '30')
			with_tag('.gap', count: 2)
			without_tag('a', text: '2')
			without_tag('a', text: '11')
		end
	end

	def page_of_30(page)
		WillPaginate::Collection.create(page, 1, 30) { |pager| pager.replace([User.first]) }
	end

	it "pads the compact list to 5 pages on the first page" do
		html = render_pagination(page_of_30(1))

		expect(html).to have_tag('.grapple-pagination__pages--compact') do
			with_tag('.current', text: '1')
			['2', '3', '30'].each { |page| with_tag('a', text: page) }
			with_tag('.gap', count: 1)
			without_tag('a', text: '4')
		end
	end

	it "pads the compact list to 5 pages on the second page" do
		html = render_pagination(page_of_30(2))

		expect(html).to have_tag('.grapple-pagination__pages--compact') do
			['1', '3', '30'].each { |page| with_tag('a', text: page) }
			with_tag('.current', text: '2')
			with_tag('.gap', count: 1)
		end
	end

	it "pads the compact list to 5 pages on the last page" do
		html = render_pagination(page_of_30(30))

		expect(html).to have_tag('.grapple-pagination__pages--compact') do
			['1', '28', '29'].each { |page| with_tag('a', text: page) }
			with_tag('.current', text: '30')
			with_tag('.gap', count: 1)
			without_tag('a', text: '27')
		end
	end

	it "shows every page in one list when there are 5 pages or fewer" do
		records = WillPaginate::Collection.create(1, 1, 5) { |pager| pager.replace([User.first]) }
		html = render_pagination(records)

		expect(html).to have_tag('.grapple-pagination__pages', count: 1)
		expect(html).not_to have_tag('.grapple-pagination__pages--compact')
		['2', '3', '4', '5'].each { |page| expect(html).to have_tag('a', text: page) }
	end

	it "renders one list when the compact list would be the same" do
		html = render_pagination(User.all.paginate(page: 1, per_page: 3))

		expect(html).to have_tag('.grapple-pagination__pages', count: 1)
		expect(html).not_to have_tag('.grapple-pagination__pages--compact')
	end

	it "lets the caller override the window" do
		html = render_pagination(middle_page_records, inner_window: 4)

		expect(html).to have_tag('.grapple-pagination__pages--full a', text: '8')
	end

	describe "Previous and Next labels" do
		def render_with_labels(settings)
			builder_class = Class.new(Grapple::DataGridBuilder) { configure :pagination, settings }
			builder = builder_class.new(self, users_columns, middle_page_records, {})
			builder.pagination
			builder.table('')
		end

		it "uses the configured labels in both lists" do
			html = render_with_labels(previous_label: 'Previous', next_label: 'Next')

			['full', 'compact'].each do |list|
				expect(html).to have_tag(".grapple-pagination__pages--#{list} a.previous_page", text: 'Previous')
				expect(html).to have_tag(".grapple-pagination__pages--#{list} a.next_page", text: 'Next')
			end
		end

		it "translates symbol labels" do
			I18n.backend.store_translations(:en, grapple_spec_previous: 'Back', grapple_spec_next: 'Forward')
			html = render_with_labels(previous_label: :grapple_spec_previous, next_label: :grapple_spec_next)

			expect(html).to have_tag('a.previous_page', text: 'Back')
			expect(html).to have_tag('a.next_page', text: 'Forward')
		end

		it "keeps will_paginate's labels when none are configured" do
			expected = template_previous_label

			expect(render_pagination(middle_page_records)).to have_tag('a.previous_page', text: expected)
		end

		def template_previous_label
			Nokogiri::HTML(will_paginate(middle_page_records)).at_css('a.previous_page').text
		end
	end

end