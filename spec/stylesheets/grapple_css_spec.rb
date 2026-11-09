require 'spec_helper'

describe 'grapple.css' do
	let(:css) { File.read(File.expand_path('../../app/assets/stylesheets/grapple.css', __dir__)) }

	def rules_with(declaration)
		css.gsub(%r{/\*.*?\*/}m, '').scan(/([^{}]+)\{([^}]*)\}/).select { |_, body| body.include?(declaration) }
			.flat_map { |selectors, _| selectors.split(',').map(&:strip) }
	end

	# An identifier without a url renders as a span, which reads as plain text
	it "underlines the identifier only when it is a link" do
		selectors = rules_with('text-decoration: underline').select { |s| s.include?('grapple-identifier__link') }

		expect(selectors).not_to be_empty
		expect(selectors).to all(include('a.grapple-identifier__link'))
	end

	describe "wrapped date range filter" do
		let(:wrapped_rules) do
			css.gsub(%r{/\*.*?\*/}m, '').scan(/([^{}]+)\{([^}]*)\}/).select { |selectors, _| selectors.include?('grapple-range--wrapped') }
		end

		it "moves From and To to their own row" do
			bodies = wrapped_rules.map(&:last).join
			expect(bodies).to include('flex-wrap: wrap')
			expect(bodies).to include('flex: 0 0 100%')
		end

		# jQuery's show() and hide() write inline display on these, and a stylesheet display would win
		it "leaves display on the elements JavaScript shows and hides alone" do
			wrapped_rules.select { |_, body| body.include?('display') }.each do |selectors, _|
				selectors.split(',').each do |selector|
					expect(selector.strip).not_to match(/(\.range-label|\.range-input|\.range-from|\.range-to|\.more-filter-wrapper)\s*\z/)
				end
			end
		end

		it "uses no !important" do
			expect(wrapped_rules.map(&:last).join).not_to include('!important')
		end
	end

	it "sizes the date dropdown to the selected option where the browser can't" do
		# Selector lists are kept whole here: the :is() inside them holds a comma
		selectors = css.gsub(%r{/\*.*?\*/}m, '').scan(/([^{}]+)\{([^}]*)\}/)
			.select { |_, body| body.include?('width: var(--grapple-select-fit, auto)') }.map(&:first)

		expect(selectors).not_to be_empty
		expect(selectors).to all(include('select:is(.relative-date, .dropdown-with-range)'))
	end
end
