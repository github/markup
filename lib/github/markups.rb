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

command(:rest2html, /rest|rst/)

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

#
# man pages!
#
command('groff -t -e -mandoc -Thtml -P -l -P -r -', /\d/) do |rendered, original|
  # Try to grab the name and section.
  if original =~ /^.TH (\S+).*?(\d).*$/
    # Clear out the gunk, "MUSTACHE" => MUSTACHE
    name, section = $1, $2
    name.gsub!(/"|'/, '')

    # make MUSTACHE(1)
    title = "#{name}(#{section})"

    # Classy divs.
    left = "<div float='left'>#{title}</div>"
    right = "<div float='right'>#{title}</div>"
  end

  if rendered =~ /<body>\s*(.+)\s*<\/body>/mi
    $1.gsub(/<hr>/, '').gsub(/(<h1.+?h1>)/, "<div>#{left}\\1#{right}</div>")
  end
end
