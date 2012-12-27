MD_FILES = /md|mkdn?|mdwn|mdown|markdown/

if markup('github/markdown', MD_FILES) do |content|
    GitHub::Markdown.render(content)
  end
elsif markup(:redcarpet, MD_FILES) do |content|
    RedcarpetCompat.new(content).to_html
  end 
elsif markup(:rdiscount, MD_FILES) do |content|
    RDiscount.new(content).to_html
  end 
elsif markup(:maruku, MD_FILES) do |content|
    Maruku.new(content).to_html
  end 
elsif markup(:kramdown, MD_FILES) do |content|
    Kramdown::Document.new(content).to_html
  end
elsif markup(:bluecloth, MD_FILES) do |content|
    BlueCloth.new(content).to_html
  end
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

markup(:wikicloth, /mediawiki|wiki/) do |content|
  WikiCloth::WikiCloth.new(:data => content).to_html(:noedit => true)
end

markup(:literati, /lhs/) do |content|
  Literati.render(content)
end

markup(:asciidoctor, /asc|adoc|asciidoc/) do |content|
  Asciidoctor::Document.new(content).render
end

command(:rest2html, /re?st(\.txt)?/)

command("/usr/bin/env perldoc -MPod::Simple::XHTML -w html_header: -w html_footer:", /pod/)

