require "github/markup/markdown"

markups << GitHub::Markup::Markdown.new

markup(:redcloth, /textile/) do |content|
  RedCloth.new(content).to_html
end

markup('github/markup/rdoc', /rdoc/) do |content|
  GitHub::Markup::RDoc.new(content).to_html
end

markup('org-ruby', /org/) do |content|
  Orgmode::Parser.new(content).to_html
end

markup(:creole, /creole/) do |content|
  Creole.creolize(content)
end

markup(:wikicloth, /mediawiki|wiki/) do |content|
  WikiCloth::WikiCloth.new(:data => content).to_html(:noedit => true)
end

markup(:literati, /lhs/) do |content|
  Literati.render(content)
end

markup(:asciidoctor, /adoc|asc(iidoc)?/) do |content|
  Asciidoctor.render(content, :safe => :secure, :attributes => %w(showtitle idprefix idseparator=- env=github env-github source-highlighter=html-pipeline))
end

command(:rest2html, /re?st(\.txt)?/)

command("/usr/bin/env perldoc -MPod::Simple::XHTML -w html_header: -w html_footer:", /pod/)

