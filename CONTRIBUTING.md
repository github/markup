# Contributing

Want to contribute? Great!

1. Fork it.
2. Create a branch (`git checkout -b my_markup`)
3. Commit your changes (`git commit -am "Added Snarkdown"`)
4. Push to the branch (`git push origin my_markup`)
5. Open a [Pull Request][1]
6. Enjoy a refreshing Diet Coke and wait


There are two ways to add markups.

### Commands

If your markup is in a language other than Ruby, drop a translator
script in `lib/github/commands` which accepts input on STDIN and
returns HTML on STDOUT. See [rest2html][r2h] for an example.

Once your script is in place, edit `lib/github/markups.rb` and tell
GitHub Markup about it. Again we look to [rest2html][r2hc] for
guidance:

    command(:rest2html, /re?st(.txt)?/)

Here we're telling GitHub Markup of the existence of a `rest2html`
command which should be used for any file ending in `rest`,
`rst`, `rest.txt` or `rst.txt`. Any regular expression will do.

Finally add your [tests](#testing).

### Classes

If your markup can be translated using a Ruby library, that's
great. Check out `lib/github/markups.rb` for some
examples. Let's look at Markdown:

    markup(:markdown, /md|mkdn?|markdown/) do |content|
      Markdown.new(content).to_html
    end

We give the `markup` method three bits of information: the name of the
file to `require`, a regular expression for extensions to match, and a
block to run with unformatted markup which should return HTML.

If you need to monkeypatch a RubyGem or something, check out the
included RDoc example.

Finally add your [tests](#testing).

### Testing

To run the tests:

    $ rake

When adding support for a new markup library, create a `README.extension` in `test/markups` along with a `README.extension.html`. As you may imagine, the `README.extension` should be your known input and the
`README.extension.html` should be the desired output.

Now run the tests: `rake`

If nothing complains, congratulations!

## Releasing a new version

If you are the current maintainer of this gem:

0. Bump the version number in `lib/github-markup.rb`, adhering to [Semantic Versioning](http://semver.org/)
0. Update `HISTORY.md`
0. Test the latest version on GitHub
  0. Build the new version with `rake build`
  0. Copy `pkg/github-markup*.gem` to `vendor/cache` in your local checkout of GitHub
  0. Update the version for `github-markup` in the `Gemfile`
  0. run `script/bootstrap`
  0. Run any relevant tests and test it manually from the browser.
0. Push the new gem release with `rake release`. If you don't have permission to release to rubygems.org, contact one of the existing owners (`gem owners github-markup`) and ask them to add you.

[1]: http://github.com/github/markup/pulls
[r2h]: lib/github/commands/rest2html
[r2hc]: lib/github/markups.rb#L51
