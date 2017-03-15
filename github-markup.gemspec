require File.expand_path("../lib/github-markup", __FILE__)

Gem::Specification.new do |s|
  s.name          = "github-markup"
  s.version       = GitHub::Markup::VERSION
  s.summary       = "The code GitHub uses to render README.markup"
  s.description   = "This gem is used by GitHub to render any fancy markup such " +
                    "as Markdown, Textile, Org-Mode, etc. Fork it and add your own!"
  s.authors       = ["Chris Wanstrath"]
  s.email         = "chris@ozmm.org"
  s.homepage      = "https://github.com/github/markup"
  s.license       = "MIT"

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = %w[lib]

  s.add_development_dependency 'activesupport', '~> 4.0'
  s.add_development_dependency 'minitest', '~> 5.4.3'
  s.add_development_dependency 'html-pipeline', '~> 1.0'
  s.add_development_dependency 'sanitize', '~> 2.1.0'
  s.add_development_dependency 'nokogiri', '~> 1.6.1'
  s.add_development_dependency 'nokogiri-diff', '~> 0.2.0'
end
