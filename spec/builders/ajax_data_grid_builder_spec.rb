require 'spec_helper'

describe 'Ajax Data Grid Builder' do
	include GrappleSpecHelper

	before do
		@output_buffer = ''
		mock_everything
	end
	
	it "container_attributes should be correct" do
		attr = Grapple::AjaxDataGridBuilder.container_attributes(self, { :id => 'my_table' })
		expect(attr[:id]).to eq "my_table"
		expect(attr[:class]).to include("grapple")
		expect(attr[:data]['grapple-ajax-url']).to eq '/mock/path'
		puts attr
	end

end