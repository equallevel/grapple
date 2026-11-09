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
end
