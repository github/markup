markup(:markdown, /md|mkdn?|markdown/) do |content|
  Markdown.new(content).to_html
end

markup(:redcloth, /textile/) do |content|
  RedCloth.new(content).to_html
end

markup('github/markup/rdoc', /rdoc/) do |content|
  GitHub::Markup::RDoc.new(content).to_html
end

command(:rest2html, /rest|rst/)

command(:asciidoc2html, /asciidoc/)

command("/usr/bin/env pod2html", /pod/) do |rendered|
  if rendered =~ /<!-- INDEX BEGIN -->\s*(.+)\s*<!-- INDEX END -->/mi
    $1
  end
end
