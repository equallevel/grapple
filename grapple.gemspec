
Gem::Specification.new do |s|
	s.name = %q{grapple}
	s.version = "0.1.8"

	s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
	s.authors = ["Edward Potocko", "Matt Maiatico", "Matt Guenzel"]
	s.date = %q{2018-02-23}
	s.description = %q{Data tables for Rails}
	s.summary = "Customizable data grid for Rails"
	s.email = %q{epotocko@equallevel.com}
	s.homepage = 'https://github.com/equallevel/grapple'
	s.files = Dir['Rakefile', '{app,config,lib,spec}/**/*', 'README*', 'LICENSE*']

	s.rdoc_options = ["--charset=UTF-8"]
	s.require_paths = ["lib"]
	s.license = 'MIT'
  
	s.required_ruby_version = '>= 1.9.3'

	s.add_dependency(%q<actionpack>, [">= 3.2.13"])
	s.add_dependency(%q<activesupport>, [">= 3.2.13"])

	s.add_development_dependency(%q<rspec-rails>, ["~> 3.0"])
	s.add_development_dependency(%q<rspec-html-matchers>, ["~> 0.7.0"])
	s.add_development_dependency(%q<rake>)
	s.add_development_dependency(%q<activemodel>, [">= 3.2.13"])
	s.add_development_dependency(%q<activerecord>, [">= 3.2.13"])
	s.add_development_dependency(%q<will_paginate>)
end
