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
 1) AAAA-AAAA   2) AAAA-AAAA
 3) AAAA-AAAA   4) AAAA-AAAA
 5) AAAA-AAAA   6) AAAA-AAAA
 7) AAAA-AAAA   8) AAAA-AAAA
 9) AAAA-AAAA  10) AAAA-AAAA
11) AAAA-AAAA  12) AAAA-AAAA
13) AAAA-AAAA  14) AAAA-AAAA
15) AAAA-AAAA  16) AAAA-AAAA
17) AAAA-AAAA  18) AAAA-AAAA
19) AAAA-AAAA  20) AAAA-AAAA
