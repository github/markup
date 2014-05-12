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

  s.add_dependency "posix-spawn", "~> 0.3.8"
end
