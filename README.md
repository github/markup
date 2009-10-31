GitHub Markup
=============

We use this library on GitHub when rendering your README or any other
rich text file.

Want to contribute? Great! There are two ways to add markups.


### Commands

If your markup is in a language other than Ruby, drop a translator
script in `lib/github/commands` which accepts input on STDIN and
returns HTML on STDOUT. See [rest2html][r2h] for an example.

Once your script is in place, edit `lib/github/markups.rb` and tell
GitHub Markup about it. Again we look to [rest2html][r2hc] for
guidance:

    command(:rest2html, /rest|rst/)

Here we're telling GitHub Markup of the existence of a `rest2html`
command which should be used for any file ending in `rest` or
`rst`. Any regular expression will do.

Finally add your tests. Create a `README.extension` in `test/markups`
along with a `README.extension.html`. As you may imagine, the
`README.extension` should be your known input and the
`README.extension.html` should be the desired output.

Now run the tests: `rake`

If nothing complains, congratulations!


### Classes

If your markup can be translated using a Ruby library, that's
great. Check out Check `lib/github/markups.rb` for some
examples. Let's look at Markdown:

    markup(:markdown, /md|mkdn?|markdown/) do |content|
      Markdown.new(content).to_html
    end

We give the `markup` method three bits of information: the name of the
file to `require`, a regular expression for extensions to match, and a
block to run with unformatted markup which should return HTML.

If you need to monkeypatch a RubyGem or something, check out the
included RDoc example.

Tests should be added in the same manner as described under the
`Commands` section.


Usage
-----

    require 'github/markup'
    GitHub::Markup.render('README.markdown', "* One\n* Two")

Or, more realistically:

    require 'github/markup'
    GitHub::Markup.render(file, File.read(file))


Contributing
------------

1. Fork it.
2. Create a branch
3. Commit your changes
4. Push to the branch
5. Create an [Issue][1] with a link to your branch
6. Enjoy a refreshing Diet Coke and wait


[r2h]: http://github.com/defunkt/github_markup/tree/master/lib/github/commands/rest2html
[r2hc]: http://github.com/defunkt/github_markup/tree/master/lib/github/markups.rb#L13
[1]: http://github.com/defunkt/github_markup/issues
