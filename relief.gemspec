# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{relief}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tyler Hunt"]
  s.date = %q{2009-05-12}
  s.email = %q{tyler@tylerhunt.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/relief.rb",
    "lib/relief/element.rb",
    "lib/relief/parser.rb",
    "spec/parser_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/tylerhunt/relief}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{An XML to hash Ruby parser DSL.}
  s.test_files = [
    "spec/parser_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.2.3"])
      s.add_development_dependency(%q<jeweler>, ["~> 0.11.0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.2.3"])
      s.add_dependency(%q<jeweler>, ["~> 0.11.0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.2.3"])
    s.add_dependency(%q<jeweler>, ["~> 0.11.0"])
  end
end
