# Contributing

This project adheres to the [Open Code of Conduct][code-of-conduct]. By participating, you are expected to honor this code.
[code-of-conduct]: http://todogroup.org/opencodeofconduct/#GitHub%20Markup/opensource@github.com

This library's only job is to decide which markup format to use and call out to an external library to convert the markup to HTML (see the [README](README.md) for more information on how markup is rendered on GitHub.com).

If you are having an issue with:

* **Syntax highlighting** - see [github/linguist](https://github.com/github/linguist/blob/master/CONTRIBUTING.md#fixing-syntax-highlighting)
* **Markdown on GitHub** - contact support@github.com
* **Styling issues on GitHub** - see [primer/markdown](https://github.com/primer/markdown)

Anything else - [search open issues](https://github.com/github/markup/issues) or create an issue and and we'll help point you in the right direction.

## Submitting a Pull Request

1. Fork it.
2. Create a branch (`git checkout -b my_markup`)
3. Commit your changes (`git commit -am "Added Snarkdown"`)
4. Push to the branch (`git push origin my_markup`)
5. Open a [Pull Request][1]
6. Enjoy a refreshing Diet Coke and wait

## Testing

To run the tests:

    $ rake

If nothing complains, congratulations!

## Releasing a new version

If you are the current maintainer of this gem:

0. Bump the version number in `lib/github-markup.rb`, adhering to [Semantic Versioning](http://semver.org/)
0. Update `HISTORY.md`
0. Test the latest version on GitHub
  0. Build the new version with `rake build`
  0. Copy `pkg/github-markup*.gem` to `vendor/cache` in your local checkout of GitHub
  0. Update the version for `github-markup` in the `Gemfile`
  0. Run `bundle update --local github-markup`
  0. Run any relevant tests and test it manually from the browser.
0. Push the new gem release with `rake release`. If you don't have permission to release to rubygems.org, contact one of the existing owners (`gem owners github-markup`) and ask them to add you.

[1]: http://github.com/github/markup/pulls
[r2h]: lib/github/commands/rest2html
[r2hc]: lib/github/markups.rb#L51
