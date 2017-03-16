GitHub Markup
=============

This library is the first step of a journey that every markup file in a repository goes on before it is rendered on GitHub.com:

0. This library converts the raw markup to HTML. See the list of [supported markup formats](#markups) below.
0. The HTML is sanitized, aggressively removing things that could harm you and your kin—such as `script` tags, inline-styles, and `class` or `id` attributes. See the [sanitization filter](https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/sanitization_filter.rb) for the full whitelist.
0. Syntax highlighting is performed on code blocks. See [github/linguist](https://github.com/github/linguist#syntax-highlighting) for more information about syntax highlighting.
0. The HTML is passed through other filters in the [html-pipeline](https://github.com/jch/html-pipeline) that add special sauce, such as [emoji](https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/emoji_filter.rb), [task lists](https://github.com/github/task_list/blob/master/lib/task_list/filter.rb), [named anchors](https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/toc_filter.rb), [CDN caching for images](https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/camo_filter.rb), and  [autolinking](https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/autolink_filter.rb).
0. The resulting HTML is rendered on GitHub.com.

Please see our [contributing guidelines](CONTRIBUTING.md) before reporting an issue.

Markups
-------

The following markups are supported.  The dependencies listed are required if
you wish to run the library. You can also run `script/bootstrap` to fetch them all.

* [.markdown, .mdown, .mkdn, .md](http://daringfireball.net/projects/markdown/) -- `gem install redcarpet` (https://github.com/vmg/redcarpet)
* [.textile](http://www.textism.com/tools/textile/) -- `gem install RedCloth`
* [.rdoc](https://rdoc.github.io/rdoc/) -- `gem install rdoc -v 3.6.1`
* [.org](http://orgmode.org/) -- `gem install org-ruby`
* [.creole](http://wikicreole.org/) -- `gem install creole`
* [.mediawiki, .wiki](http://www.mediawiki.org/wiki/Help:Formatting) -- `gem install wikicloth`
* [.rst](http://docutils.sourceforge.net/rst.html) -- `python3 -m pip install sphinx`
* [.asciidoc, .adoc, .asc](http://asciidoc.org/) -- `gem install asciidoctor` (http://asciidoctor.org)
* [.pod](http://search.cpan.org/dist/perl/pod/perlpod.pod) -- `Pod::Simple::XHTML`
  comes with Perl >= 5.10. Lower versions should install Pod::Simple from CPAN.


Installation
-----------

```
gem install github-markup
```

Usage
-----

Basic form:

```ruby
require 'github/markup'

GitHub::Markup.render('README.markdown', '* One\n* Two')
```

More realistic form:

```ruby
require 'github/markup'

GitHub::Markup.render(file, File.read(file))
```

And a convenience form:

```ruby
require 'github/markup'

GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, '* One\n* Two')
```


Contributing
------------

See [Contributing](CONTRIBUTING.md)
