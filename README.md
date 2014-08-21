GitHub Markup
=============

We use this library on GitHub when rendering your README or any other
rich text file. The generated HTML is then run through filters in the [html-pipeline](https://github.com/jch/html-pipeline) to perform things like [sanitization](#html-sanitization) and [syntax highlighting](https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/syntax_highlight_filter.rb).

Markups
-------

The following markups are supported.  The dependencies listed are required if
you wish to run the library. You can also run `script/bootstrap` to fetch them all.

* [.markdown, .mdown, .mkdn, .md](http://daringfireball.net/projects/markdown/) -- `gem install redcarpet` (https://github.com/vmg/redcarpet)
* [.textile](http://www.textism.com/tools/textile/) -- `gem install RedCloth`
* [.rdoc](http://rdoc.sourceforge.net/) -- `gem install rdoc -v 3.6.1`
* [.org](http://orgmode.org/) -- `gem install org-ruby`
* [.creole](http://wikicreole.org/) -- `gem install creole`
* [.mediawiki, .wiki](http://www.mediawiki.org/wiki/Help:Formatting) -- `gem install wikicloth`
* [.rst](http://docutils.sourceforge.net/rst.html) -- `easy_install docutils`
* [.asciidoc, .adoc, .asc](http://asciidoc.org/) -- `gem install asciidoctor` (http://asciidoctor.org)
* [.pod](http://search.cpan.org/dist/perl/pod/perlpod.pod) -- `Pod::Simple::HTML`
  comes with Perl >= 5.10. Lower versions should install Pod::Simple from CPAN.

Installation
-----------

    gem install github-markup

Usage
-----

    require 'github/markup'
    GitHub::Markup.render('README.markdown', "* One\n* Two")

Or, more realistically:

    require 'github/markup'
    GitHub::Markup.render(file, File.read(file))

Contributing
------------

See [Contributing](CONTRIBUTING.md)

HTML sanitization
-----------------

HTML rendered by the various markup language processors gets passed through an [HTML sanitization filter](https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/sanitization_filter.rb) for security reasons. HTML elements not in the whitelist are removed. HTML attributes not in the whitelist are removed from the preserved elements.

The following HTML elements, organized by category, are whitelisted:

<dl>
  <dt>Headings</dt>
  <dd>
  <ul>
    <li><code>h1</code></li>
    <li><code>h2</code></li>
    <li><code>h3</code></li>
    <li><code>h4</code></li>
    <li><code>h5</code></li>
    <li><code>h6</code></li>
    <li><code>h7</code></li>
    <li><code>h8</code></li>
  </ul>
  </dd>

  <dt>Prose</dt>
  <dd>
  <ul>
    <li><code>p</code></li>
    <li><code>div</code></li>
    <li><code>blockquote</code></li>
  </ul>
  </dd>

  <dt>Formatted</dt>
  <dd>
  <ul>
    <li><code>pre</code></li>
  </ul>
  </dd>

  <dt>Inline</dt>
  <dd>
  <ul>
    <li><code>b</code></li>
    <li><code>i</code></li>
    <li><code>strong</code></li>
    <li><code>em</code></li>
    <li><code>tt</code></li>
    <li><code>code</code></li>
    <li><code>ins</code></li>
    <li><code>del</code></li>
    <li><code>sup</code></li>
    <li><code>sub</code></li>
    <li><code>kbd</code></li>
    <li><code>samp</code></li>
    <li><code>q</code></li>
    <li><code>var</code></li>
  </ul>
  </dd>

  <dt>Lists</dt>
  <dd>
  <ul>
    <li><code>ol</code></li>
    <li><code>ul</code></li>
    <li><code>li</code></li>
    <li><code>dl</code></li>
    <li><code>dt</code></li>
    <li><code>dd</code></li>
  </ul>
  </dd>

  <dt>Tables</dt>
  <dd>
  <ul>
    <li><code>table</code></li>
    <li><code>thead</code></li>
    <li><code>tbody</code></li>
    <li><code>tfoot</code></li>
    <li><code>tr</code></li>
    <li><code>td</code></li>
    <li><code>th</code></li>
  </ul>
  </dd>

  <dt>Breaks</dt>
  <dd>
  <ul>
    <li><code>br</code></li>
    <li><code>hr</code></li>
  </ul>
  </dd>

  <dt>Ruby (East Asian)</dt>
  <dd>
  <ul>
    <li><code>ruby</code></li>
    <li><code>rt</code></li>
    <li><code>rp</code></li>
  </ul>
  </dd>
</dl>

The following attributes, organized by element, are whitelisted:

<dl>
  <dt><code>a</code></dt>
  <dd>
  <ul>
    <li><code>href</code> (<code>http://</code>, <code>https://</code>, <code>mailto://</code>, <code>github-windows://</code>, and <code>github-mac://</code> URI schemes and relative paths only)</li>
  </ul>
  </dd>

  <dt><code>img</code></dt>
  <dd>
  <ul>
    <li><code>src</code> (<code>http://</code> and <code>https://</code> URI schemes and relative paths only)</li>
  </ul>
  </dd>

  <dt><code>div</code></dt>
  <dd>
  <ul>
    <li><code>itemscope</code></li>
    <li><code>itemtype</code></li>
  </ul>
  </dd>

  <dt>All</dt>
  <dd>
  <ul>
    <li><code>abbr</code></li>
    <li><code>accept</code></li>
    <li><code>accept-charset</code></li>
    <li><code>accesskey</code></li>
    <li><code>action</code></li>
    <li><code>align</code></li>
    <li><code>alt</code></li>
    <li><code>axis</code></li>
    <li><code>border</code></li>
    <li><code>cellpadding</code></li>
    <li><code>cellspacing</code></li>
    <li><code>char</code></li>
    <li><code>charoff</code></li>
    <li><code>charset</code></li>
    <li><code>checked</code></li>
    <li><code>cite</code></li>
    <li><code>clear</code></li>
    <li><code>cols</code></li>
    <li><code>colspan</code></li>
    <li><code>color</code></li>
    <li><code>compact</code></li>
    <li><code>coords</code></li>
    <li><code>datetime</code></li>
    <li><code>dir</code></li>
    <li><code>disabled</code></li>
    <li><code>enctype</code></li>
    <li><code>for</code></li>
    <li><code>frame</code></li>
    <li><code>headers</code></li>
    <li><code>height</code></li>
    <li><code>hreflang</code></li>
    <li><code>hspace</code></li>
    <li><code>ismap</code></li>
    <li><code>label</code></li>
    <li><code>lang</code></li>
    <li><code>longdesc</code></li>
    <li><code>maxlength</code></li>
    <li><code>media</code></li>
    <li><code>method</code></li>
    <li><code>multiple</code></li>
    <li><code>name</code></li>
    <li><code>nohref</code></li>
    <li><code>noshade</code></li>
    <li><code>nowrap</code></li>
    <li><code>prompt</code></li>
    <li><code>readonly</code></li>
    <li><code>rel</code></li>
    <li><code>rev</code></li>
    <li><code>rows</code></li>
    <li><code>rowspan</code></li>
    <li><code>rules</code></li>
    <li><code>scope</code></li>
    <li><code>selected</code></li>
    <li><code>shape</code></li>
    <li><code>size</code></li>
    <li><code>span</code></li>
    <li><code>start</code></li>
    <li><code>summary</code></li>
    <li><code>tabindex</code></li>
    <li><code>target</code></li>
    <li><code>title</code></li>
    <li><code>type</code></li>
    <li><code>usemap</code></li>
    <li><code>valign</code></li>
    <li><code>value</code></li>
    <li><code>vspace</code></li>
    <li><code>width</code></li>
    <li><code>itemprop</code></li>
  </ul>
  </dd>
</dl>

Note that the `id` attribute is *not* whitelisted.
