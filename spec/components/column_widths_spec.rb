require 'spec_helper'

describe 'column widths' do
	include GrappleSpecHelper

	columns = [
		{ label: 'Name', width: 72 },
		{ label: 'Suppliers', min_width: 150 },
		{ label: 'User', min_width: 100, max_width: 150 },
		{ label: 'Notes' }
	]

	before do
		@output_buffer = ''
		mock_everything
	end

	def strict_builder(cols)
		Grapple::DataGridBuilder.new(self, cols, users_records, {}, strict_widths: true)
	end

	def heading_styles(cols)
		html = strict_builder(cols).column_headings
		Nokogiri::HTML.fragment(html).css('th').map { |th| th['style'] }
	end

	it "keeps width as a <col> hint without strict_widths" do
		builder = Grapple::DataGridBuilder.new(self, columns, users_records, {})

		expect(builder.colgroup).to have_tag('col', with: { width: '72' })
		expect(builder.column_headings).not_to have_tag('th[style]')
		expect(builder.table('')).not_to have_tag('table.grapple-strict-widths')
	end

	it "marks the table and leaves the <col> elements without widths" do
		builder = strict_builder(columns)

		expect(builder.table('')).to have_tag('table.grapple-strict-widths')
		expect(builder.colgroup).to have_tag('col', count: columns.length)
		expect(builder.colgroup).not_to have_tag('col[width]')
	end

	it "keeps the caller's table classes" do
		builder = strict_builder(columns)

		expect(builder.table('', class: 'table')).to have_tag('table.table.grapple-strict-widths')
	end

	it "sets the content width and minimum on each heading" do
		expect(heading_styles(columns)).to eq([
			'--grapple-col-width: 72px; --grapple-col-min: 72px',
			'--grapple-col-min: 150px',
			'--grapple-col-width: 150px; --grapple-col-min: 100px',
			nil
		])
	end

	# width is fixed; max_width caps an otherwise variable column; min_width is its floor
	it "maps any combination of width options to the heading's custom properties" do
		random = Random.new(10862)
		200.times do
			column = { label: 'Column' }
			[:width, :min_width, :max_width].each do |key|
				column[key] = random.rand(1..400) if random.rand < 0.5
			end
			expected_width = column[:width] || column[:max_width]
			expected_min = column[:width] || column[:min_width]

			style = heading_styles([column]).first.to_s

			expect(style[/--grapple-col-width: (\d+)px/, 1]&.to_i).to eq(expected_width), column.inspect
			expect(style[/--grapple-col-min: (\d+)px/, 1]&.to_i).to eq(expected_min), column.inspect
		end
	end

end
