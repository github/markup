GitHub Markup
=============

We use this library on GitHub when rendering you README or any other
rich text file.

Want to add your own? Check `lib/github/markups.rb` for the definition
file.

Even if you don't know Ruby we welcome you with open arms. Check
`lib/github/commands/asciidoc2html` or `lib/github/commands/rest2html`
for examples of Python implementations.


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


Authors
-------

Chris Wanstrath and all of you

[1]: http://github.com/defunkt/github_markup/issues
