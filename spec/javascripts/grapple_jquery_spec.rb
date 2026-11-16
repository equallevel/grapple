require 'spec_helper'

describe 'grapple-jquery.js' do
	let(:js) { File.read(File.expand_path('../../app/assets/javascripts/grapple-jquery.js', __dir__)) }

	# COBRA-11207: between 501 and 760px filters that don't fit one row wrap instead of stacking
	it "stacks the filters one per row only at 500px and below" do
		expect(js).to include("GrappleTable.STACKED_QUERY = '(max-width: 500px)';")
		expect(js).to match(/matchMedia\(GrappleTable\.STACKED_QUERY\)/)
	end

	# The Actions only take room on the search row, so ranges wrap against the full toolbar width
	it "wraps date ranges at the desktop breakpoint against the toolbar width" do
		layout = js[/layoutToolbar: function\(toolbar\) \{.*?\n\t\},/m]
		desktop = layout[/if\(window\.matchMedia\(GrappleTable\.DESKTOP_QUERY\)\.matches\) \{.*?\}/m]
		expect(layout).to include('var available = $(cell).width();')
		expect(desktop).to include('this._wrapRanges(toolbar, available);')
		expect(desktop).to include('this._fillSearchRow(cell, filters, gap);')
	end

	it "moves the filters that don't fit beside the search and the Actions to the rows below" do
		fill = js[/_fillSearchRow: function\(cell, filters, gap\) \{.*?\n\t\},/m]
		expect(js).to include("GrappleTable.CSS_NEXT_ROW = 'grapple-toolbar__next-row';")
		expect(fill).to include('$(item).addClass(GrappleTable.CSS_NEXT_ROW);')
		# The Actions' auto margin would count the row's free space
		expect(fill).to include('var used = actions.getBoundingClientRect().width;')
	end
end
