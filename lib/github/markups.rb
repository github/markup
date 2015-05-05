require "github/markup/markdown"
require "github/markup/rdoc"
require "shellwords"

module GitHub
  module Markups
    # all of supported markups:
    MARKUP_ASCIIDOC = :asciidoc
    MARKUP_CREOLE = :creole
    MARKUP_MARKDOWN = :markdown
    MARKUP_MEDIAWIKI = :mediawiki
    MARKUP_ORG = :org
    MARKUP_POD = :pod
    MARKUP_RDOC = :rdoc
    MARKUP_RST = :rst
    MARKUP_TEXTILE = :textile
  end
end

markup(GitHub::Markups::MARKUP_MARKDOWN, GitHub::Markup::Markdown.new)

markup(GitHub::Markups::MARKUP_TEXTILE, :redcloth, /textile/) do |content|
  RedCloth.new(content).to_html
end

markup(GitHub::Markups::MARKUP_RDOC, GitHub::Markup::RDoc.new)

markup(GitHub::Markups::MARKUP_ORG, 'org-ruby', /org/) do |content|
  Orgmode::Parser.new(content, {
                        :allow_include_files => false,
                        :skip_syntax_highlight => true
                      }).to_html
end

markup(GitHub::Markups::MARKUP_CREOLE, :creole, /creole/) do |content|
  Creole.creolize(content)
end

markup(GitHub::Markups::MARKUP_MEDIAWIKI, :wikicloth, /mediawiki|wiki/) do |content|
  WikiCloth::WikiCloth.new(:data => content).to_html(:noedit => true)
end

markup(GitHub::Markups::MARKUP_ASCIIDOC, :asciidoctor, /adoc|asc(iidoc)?/) do |content|
  Asciidoctor.render(content, :safe => :secure, :attributes => %w(showtitle idprefix idseparator=- env=github env-github source-highlighter=html-pipeline))
end

command(
  GitHub::Markups::MARKUP_RST,
  "python2 -S #{Shellwords.escape(File.dirname(__FILE__))}/commands/rest2html",
  /re?st(\.txt)?/,
  "restructuredtext"
)

# pod2html is nice enough to generate a full-on HTML document for us,
# so we return the favor by ripping out the good parts.
#
# Any block passed to `command` will be handed the command's STDOUT for
# post processing.
command(GitHub::Markups::MARKUP_POD, '/usr/bin/env perl -MPod::Simple::HTML -e Pod::Simple::HTML::go', /pod/, "pod") do |rendered|
  if rendered =~ /<!-- start doc -->\s*(.+)\s*<!-- end doc -->/mi
    $1
  end
end
