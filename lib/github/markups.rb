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

markup(:hikidoc, /hiki/) do |content|
  HikiDoc.to_html(content)
end

command(:rest2html, /re?st(\.txt)?/)

command('asciidoc -s --backend=xhtml11 -o - -', /asciidoc/)

# pod2html is nice enough to generate a full-on HTML document for us,
# so we return the favor by ripping out the good parts.
#
# Any block passed to `command` will be handed the command's STDOUT for
# post processing.
command("/usr/bin/env perl -MPod::Simple::HTML -e Pod::Simple::HTML::go", /pod/) do |rendered|
  if rendered =~ /<!-- start doc -->\s*(.+)\s*<!-- end doc -->/mi
    $1
  end
end
