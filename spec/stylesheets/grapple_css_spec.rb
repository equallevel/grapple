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

	# Contents of every @media block with this condition, comments removed
	def media_blocks(condition)
		source = css.gsub(%r{/\*.*?\*/}m, '')
		blocks = []
		index = 0
		while (start = source.index("@media #{condition}", index))
			open = source.index('{', start)
			depth = 0
			close = open
			source[open..].each_char.with_index do |char, offset|
				depth += 1 if char == '{'
				depth -= 1 if char == '}'
				if depth.zero?
					close = open + offset
					break
				end
			end
			blocks << source[(open + 1)...close]
			index = close
		end
		blocks.join("\n")
	end

	def rule_bodies(source, selector_part)
		source.scan(/([^{}]+)\{([^}]*)\}/).select { |selectors, _| selectors.include?(selector_part) }.map(&:last)
	end

	# Global Components 206:124 and the Requisitions frames: 47px header, 51px rows
	describe "desktop cell padding" do
		let(:desktop) { media_blocks('(min-width: 761px)') }

		it "is 12px on every side" do
			expect(desktop).to include('--grapple-cell-padding: 12px;')
			expect(desktop).to include('--grapple-pinned-padding: 12px;')
		end

		it "keeps 12px above and below the 3-dot and identifier cells at every width" do
			source = css.gsub(%r{/\*.*?\*/}m, '')
			['td.grapple-row-controls', 'td.grapple-identifier-cell'].each do |cell|
				paddings = rule_bodies(source, cell).flat_map { |body| body.scan(/padding:\s*([^;]+);/).flatten }
				expect(paddings).not_to be_empty
				paddings.each { |value| expect(value.split.first).to eq('12px') }
			end
		end
	end

	# Global Components 207:3860: "Select State" in #6d717e until an option is picked
	it "greys an added filter's placeholder until an option is selected" do
		selectors = rules_with('color: var(--grapple-text-subtle)')

		expect(selectors).to include(a_string_matching(
			/\.more-filter-wrapper .*\.ms-options-wrap:not\(\.ms-has-selections\) > button\z/
		))
	end

	describe "pagination too wide for one row" do
		let(:desktop) { media_blocks('(min-width: 761px)') }

		it "shows the compact list instead of the full one" do
			full = rule_bodies(desktop, '.grapple-pagination--compact .grapple-pagination__pages--full').join
			compact = rule_bodies(desktop, '.grapple-pagination--compact .grapple-pagination__pages--compact').join

			expect(full).to include('display: none')
			expect(compact).to include('display: block')
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
