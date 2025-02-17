require File.expand_path("../lib/github-markup", __FILE__)

Gem::Specification.new do |s|
  s.name          = "github-markup"
  s.version       = GitHub::Markup::VERSION
  s.summary       = "The code GitHub uses to render README.markup"
  s.description   = <<~DESC
    This gem is used by GitHub to render any fancy markup such as Markdown,
    Textile, Org-Mode, etc. Fork it and add your own!
  DESC
  s.authors       = ["Chris Wanstrath"]
  s.email         = "chris@ozmm.org"
  s.homepage      = "https://github.com/github/markup"
  s.license       = "MIT"

  s.required_ruby_version = '>= 3.0.0'

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = %w[lib]

  s.add_development_dependency 'rake', '~> 12'
  s.add_development_dependency 'activesupport', '~> 7.1.5'
  s.add_development_dependency 'minitest', '~> 5.4', '>= 5.4.3'
  s.add_development_dependency 'html-pipeline', '~> 1.0'
  s.add_development_dependency 'sanitize', '>= 4.6.3'
  s.add_development_dependency 'nokogiri', '~> 1.17.2'
  s.add_development_dependency 'nokogiri-diff', '~> 0.3.0'
  s.add_development_dependency "github-linguist", ">= 7.1.3"
end
