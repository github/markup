require "github/markup/markdown"
require "github/markup/rdoc"
require "shellwords"

markups << GitHub::Markup::Markdown.new

markup(:redcloth, /textile/) do |content|
  RedCloth.new(content).to_html
end

markups << GitHub::Markup::RDoc.new

markup('org-ruby', /org/) do |content|
  Orgmode::Parser.new(content, {
                        :allow_include_files => false,
                        :skip_syntax_highlight => true
                      }).to_html
end

markup(:creole, /creole/) do |content|
  Creole.creolize(content)
end

markup(:wikicloth, /mediawiki|wiki/) do |content|
  wikicloth = WikiCloth::WikiCloth.new(:data => content)
  WikiCloth::WikiBuffer::HTMLElement::ESCAPED_TAGS << 'tt'
  wikicloth.to_html(:noedit => true)
end

markup(:asciidoctor, /adoc|asc(iidoc)?/) do |content|
  Asciidoctor::Compliance.unique_id_start_index = 1
  Asciidoctor.convert(content, :safe => :secure, :attributes => %w(showtitle=@ idprefix idseparator=- env=github env-github source-highlighter=html-pipeline))
end

command(
  "python2 -S #{Shellwords.escape(File.dirname(__FILE__))}/commands/rest2html",
  /re?st(\.txt)?/,
  "restructuredtext"
)

# pod2html is nice enough to generate a full-on HTML document for us,
# so we return the favor by ripping out the good parts.
#
# Any block passed to `command` will be handed the command's STDOUT for
# post processing.
command('/usr/bin/env perl -MPod::Simple::HTML -e Pod::Simple::HTML::go', /pod/, "pod") do |rendered|
  if rendered =~ /<!-- start doc -->\s*(.+)\s*<!-- end doc -->/mi
    $1
  end
end
