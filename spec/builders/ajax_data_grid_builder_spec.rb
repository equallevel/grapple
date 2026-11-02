require 'spec_helper'

describe 'Ajax Data Grid Builder' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
	end
	
	it "container_attributes should be correct" do
		builder = Grapple::AjaxDataGridBuilder.new(self, [], [], {}, id: 'my_table')
		attr = builder.container_attributes()
		expect(attr[:id]).to eq "my_table"
		expect(attr[:class]).to include("grapple")
		expect(attr[:data]['grapple-ajax-url']).to eq '/mock/path'
	end

	it "container_attributes should include the empty search message" do
		builder = Grapple::AjaxDataGridBuilder.new(self, [], [], {}, id: 'my_table')

		expect(builder.container_attributes[:data]['grapple-search-required-message']).to eq 'A search term is required'
	end

end