GitHub Markup
=============

This library is the **first step** of a journey that every markup file in a repository goes on before it is rendered on GitHub.com:

1. `github-markup` selects an _underlying library_ to convert the raw markup to HTML. See the list of [supported markup formats](#markups) below.
1. The HTML is sanitized, aggressively removing things that could harm you and your kin—such as `script` tags, inline-styles, and `class` or `id` attributes.
1. Syntax highlighting is performed on code blocks. See [github/linguist](https://github.com/github/linguist#syntax-highlighting) for more information about syntax highlighting.
1. The HTML is passed through other filters that add special sauce, such as emoji, task lists, named anchors, CDN caching for images, and autolinking.
1. The resulting HTML is rendered on GitHub.com.

Please note that **only the first step** is covered by this gem — the rest happens on GitHub.com.  In particular, `markup` itself does no sanitization of the resulting HTML, as it expects that to be covered by whatever pipeline is consuming the HTML.

Please see our [contributing guidelines](CONTRIBUTING.md) before reporting an issue.

Markups
-------

The following markups are supported.  The dependencies listed are required if
you wish to run the library. You can also run `script/bootstrap` to fetch them all.

* [.markdown, .mdown, .mkdn, .md](http://daringfireball.net/projects/markdown/) -- `gem install commonmarker` (https://github.com/gjtorikian/commonmarker)
* [.textile](https://textile-lang.com/) -- `gem install RedCloth` (https://github.com/jgarber/redcloth)
* [.rdoc](https://ruby.github.io/rdoc/) -- `gem install rdoc -v 3.6.1`
* [.org](http://orgmode.org/) -- `gem install org-ruby` (https://github.com/wallyqs/org-ruby)
* [.creole](http://wikicreole.org/) -- `gem install creole` (https://github.com/larsch/creole)
* [.mediawiki, .wiki](http://www.mediawiki.org/wiki/Help:Formatting) -- `gem install wikicloth` (https://github.com/nricciar/wikicloth)
* [.rst](http://docutils.sourceforge.net/rst.html) -- `pip install docutils`
* [.asciidoc, .adoc, .asc](http://asciidoc.org/) -- `gem install asciidoctor` (http://asciidoctor.org).
  Optionally `gem install asciidoctor-diagram` to render diagram blocks; see
  [Diagrams in AsciiDoc](#diagrams-in-asciidoc).
* [.pod](http://search.cpan.org/dist/perl/pod/perlpod.pod) -- `Pod::Simple::XHTML`
  comes with Perl >= 5.10. Lower versions should install Pod::Simple from CPAN.

Installation
-----------

```
gem install github-markup
```

or

```
bundle install
```

from this directory.

Usage
-----

Basic form:

```ruby
require 'github/markup'

GitHub::Markup.render('README.markdown', "* One\n* Two")
```

More realistic form:

```ruby
require 'github/markup'

GitHub::Markup.render(file, File.read(file))
```

And a convenience form:

```ruby
require 'github/markup'

GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, "* One\n* Two")
```

Diagrams in AsciiDoc
--------------------

Diagram blocks in AsciiDoc files -- PlantUML, C4, Mermaid, Graphviz, D2,
Structurizr and friends -- are rendered as images when
[asciidoctor-diagram](https://github.com/asciidoctor/asciidoctor-diagram) is
installed:

```asciidoc
[plantuml]
----
@startuml
!include <C4/C4_Container>
Person(user, "User")
Container(api, "API", "Ruby")
Rel(user, api, "uses", "HTTPS")
@enduml
----
```

The diagram is rendered locally and inlined as a data URI, so the output stays
self-contained and does not depend on where the generated file landed:

```html
<img src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGlu..." alt="plantuml diagram">
```

**A data URI only survives a sanitizer that allows the `data:` protocol on
`img/src`, and the stock html-pipeline config does not** -- it keeps the `<img>`
but drops the `src`, leaving a broken image. If you sanitize the output of this
library (as [the pipeline described above](#github-markup) does), allow the
protocol:

```ruby
config = HTMLPipeline::SanitizationFilter::DEFAULT_CONFIG
img = config[:protocols]["img"]
config = config.merge(
  protocols: config[:protocols].merge(
    "img" => img.merge("src" => img["src"] + ["data"])
  )
)
```

Rendering a diagram needs the toolchain for its type -- a JVM for PlantUML (see
`asciidoctor-diagram-plantuml`, which bundles the JAR), Graphviz for `dot`, the
`d2` binary for D2, and so on. Install the gem alongside this one:

```
gem install asciidoctor-diagram asciidoctor-diagram-plantuml
```

When the gem is not installed, or the toolchain a diagram type needs is missing,
the block falls back to a source block that keeps the diagram language on the
`<pre>`, so a client-side renderer can still pick it up:

```html
<pre lang="plantuml"><code>@startuml ...</code></pre>
```

Nothing is enabled by default: a plain install never depends on a diagram
toolchain, and always produces the tagged source block above.

Choosing an output format (`svg` or `png`), per block:

```asciidoc
[plantuml,format=png]
----
@startuml
Alice -> Bob: hi
@enduml
----
```

Local Development
-----------------

```sh
python3 -m venv .venv
source .venv/bin/activate
cd script
./bootstrap
```

Contributing
------------

See [Contributing](CONTRIBUTING.md).
