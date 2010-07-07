$LOAD_PATH.unshift 'lib'
require "github/markup/version"

Gem::Specification.new do |s|
  s.name              = "github-markup"
  s.version           = GitHub::Markup::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "The code GitHub uses to render README.markup"
  s.homepage          = "http://github.com/github/markup"
  s.email             = "chris@ozmm.org"
  s.authors           = [ "Chris Wanstrath" ]
  s.has_rdoc          = false

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("man/**/*")
  s.files            += Dir.glob("test/**/*")

#  s.executables       = %w( github-markup )
  s.description       = <<desc
  This gem is used by GitHub to render any fancy markup such as
  Markdown, Textile, Org-Mode, etc. Fork it and add your own!
desc
end
