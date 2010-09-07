markup(:markdown, /md|mkdn?|mdown|markdown/) do |content|
  Markdown.new(content).to_html
end

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

command(:rest2html, /re?st(\.txt)?/)

command('asciidoc -s --backend=xhtml11 -o - -', /asciidoc/)

command("/usr/bin/env perldoc -MPod::Simple::XHTML -w html_header: -w html_footer:", /pod/)

