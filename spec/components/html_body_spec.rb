require 'spec_helper'

describe 'html body' do
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
		builder = Grapple::HtmlTableBuilder.new(self, columns, records, {})

		html = builder.body(tr: false) do |item|
			concat((
				"<tr>\n\t\t<td>#{item.login}</td>\n\t\t" + 
				'<td class="text-right">' + item.firstname + '</td>' +
				"</tr>"
			).html_safe)
		end

		#puts html

		expect(html).to have_tag('tbody') do
			with_tag('tr', count: records.length)

			records.each do |user|
				with_tag('tr') do
					with_tag("td") do
						with_text(user.login)
					end

					with_tag("td") do
						with_text(user.firstname)
					end
				end
			end

		end
		
	end

end