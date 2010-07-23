# asciidoc
command('asciidoc --safe --backend=xhtml11 -o - -', /asciidoc/) do |rendered|
  if rendered =~ /<body>\n(.*)<div id="footnotes">/m
    $1
  end
end

# creole
markup(:creole, /creole/) do |content|
  Creole.creolize(content)
end

# markdown
markup(:markdown, /md|mkdn?|mdown|markdown/) do |content|
  Markdown.new(content).to_html
end

# org
markup('org-ruby', /org/) do |content|
  Orgmode::Parser.new(content).to_html
end

# pod
command("/usr/bin/env perl -MPod::Simple::HTML -e Pod::Simple::HTML::go", /pod/) do |rendered|
  if rendered =~ /<!-- start doc -->\s*(.+)\s*<!-- end doc -->/mi
    $1
  end
end

# rdoc
markup('github/markup/rdoc', /rdoc/) do |content|
  GitHub::Markup::RDoc.new(content).to_html
end

# rest
command(:rest2html, /re?st(\.txt)?/)

# textile
markup(:redcloth, /textile/) do |content|
  RedCloth.new(content).to_html
end
