version_file = File.expand_path("../lib/github-markup.rb", __FILE__)
version_match = File.read(version_file).match(/VERSION = ['"]([^'"]+)['"]/)
raise "Could not find VERSION in #{version_file}" unless version_match
version = version_match[1]

Gem::Specification.new do |s|
  s.name          = "github-markup"
  s.version       = version
  s.summary       = "The code GitHub uses to render README.markup"
  s.description   = <<~DESC
    This gem is used by GitHub to render any fancy markup such as Markdown,
    Textile, Org-Mode, etc. Fork it and add your own!
  DESC
  s.authors       = ["Chris Wanstrath"]
  s.email         = "chris@ozmm.org"
  s.homepage      = "https://github.com/github/markup"
  s.license       = "MIT"

  s.required_ruby_version = '>= 3.3.0'

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = %w[lib]

  s.add_development_dependency 'rake', '~> 13'
  s.add_development_dependency 'activesupport', '~> 8.1.3'
  s.add_development_dependency 'minitest', '>= 5.4.3', '~> 6.0'
  s.add_development_dependency 'html-pipeline', '~> 1.0'
  s.add_development_dependency 'sanitize', '>= 4.6.3'
  s.add_development_dependency 'nokogiri', '~> 1.19.2'
  s.add_development_dependency 'nokogiri-diff', '~> 0.3.0'
  s.add_development_dependency "github-linguist", ">= 7.1.3"
  s.add_development_dependency 'simplecov', '~> 0.22'
end
