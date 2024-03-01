# frozen_string_literal: true

require_relative "lib/github/markup/version"

Gem::Specification.new do |spec|
  spec.name        = "github-markup"
  spec.version     = GitHub::Markup::VERSION
  spec.homepage    = "https://github.com/github/markup"
  spec.summary     = "The code GitHub uses to render README.markup"
  spec.description = <<~DESC
  This gem is used by GitHub to render any fancy markup such as Markdown,
  Textile, Org-Mode, etc. Fork it and add your own!
DESC
  spec.authors      = ["Chris Wanstrath", "Rob Crouch"]
  spec.license      = "MIT"

  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/github/markup/issues",
    "source_code_uri"   => "https://github.com/github/markup"
  }

  spec.required_ruby_version = ">= 2.4"

  spec.files         = Dir.glob("lib/**/*", File::FNM_DOTMATCH)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_development_dependency 'rake', '~> 13.1'
  spec.add_development_dependency 'activesupport', '~> 7.1', '>= 7.1.3.2'
  spec.add_development_dependency 'minitest', '~> 5.4', '>= 5.4.3'
  spec.add_development_dependency 'html-pipeline', '~> 1.0'
  spec.add_development_dependency "sanitize", "~> 4.6", ">= 4.6.3"
  spec.add_development_dependency 'nokogiri', '~> 1.8.1'
  spec.add_development_dependency 'nokogiri-diff', '~> 0.2.0'
  spec.add_development_dependency "github-linguist", "~> 7.1", ">= 7.1.3"


end