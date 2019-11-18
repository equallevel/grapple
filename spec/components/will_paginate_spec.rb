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

end