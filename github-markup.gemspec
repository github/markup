## This is the rakegem gemspec template. Make sure you read and understand
## all of the comments. Some sections require modification, and others can
## be deleted if you don't need them. Once you understand the contents of
## this file, feel free to delete any comments that begin with two hash marks.
## You can find comprehensive Gem::Specification documentation, at
## http://docs.rubygems.org/read/chapter/20
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  ## Leave these as is they will be modified for you by the rake gemspec task.
  ## If your rubyforge_project name is different, then edit it and comment out
  ## the sub! line in the Rakefile
  s.name              = 'github-markup'
  s.version           = '0.7.4'
  s.date              = '2012-07-19'
  s.executables       = ['github-markup']

  ## Make sure your summary is short. The description may be as long
  ## as you like.
  s.summary     = "The code GitHub uses to render README.markup"
  s.description = <<desc
  This gem is used by GitHub to render any fancy markup such as
  Markdown, Textile, Org-Mode, etc. Fork it and add your own!
desc

  ## List the primary authors. If there are a bunch of authors, it's probably
  ## better to set the email to an email list or something. If you don't have
  ## a custom homepage, consider using your GitHub URL or the like.
  s.authors  = ["Chris Wanstrath"]
  s.email    = 'chris@ozmm.org'
  s.homepage = 'https://github.com/github/markup'

  ## This gets added to the $LOAD_PATH so that 'lib/NAME.rb' can be required as
  ## require 'NAME.rb' or'/lib/NAME/file.rb' can be as require 'NAME/file.rb'
  s.require_paths = %w[lib]

  ## Specify any RDoc options here. You'll want to add your README and
  ## LICENSE files to the extra_rdoc_files list.
  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  ## List your runtime dependencies here. Runtime dependencies are those
  ## that are needed for an end user to actually USE your code.
  #s.add_dependency('simple_uuid', "~> 0.1.2")

  ## List your development dependencies here. Development dependencies are
  ## those that are only needed during development
  #s.add_development_dependency("test-unit", "~> 2.3.0")

  ## Leave this section as-is. It will be automatically generated from the
  ## contents of your Git repository via the gemspec task. DO NOT REMOVE
  ## THE MANIFEST COMMENTS, they are used as delimiters by the task.
  # = MANIFEST =
  s.files = %w[
    Gemfile
    HISTORY.md
    LICENSE
    README.md
    Rakefile
    bin/github-markup
    github-markup.gemspec
    lib/github-markup.rb
    lib/github/commands/asciidoc2html
    lib/github/commands/asciidocapi.py
    lib/github/commands/rest2html
    lib/github/markup.rb
    lib/github/markup/rdoc.rb
    lib/github/markups.rb
    test/markup_test.rb
    test/markups/README.asciidoc
    test/markups/README.asciidoc.html
    test/markups/README.creole
    test/markups/README.creole.html
    test/markups/README.markdown
    test/markups/README.markdown.html
    test/markups/README.mediawiki
    test/markups/README.mediawiki.html
    test/markups/README.noformat
    test/markups/README.noformat.html
    test/markups/README.org
    test/markups/README.org.html
    test/markups/README.pod
    test/markups/README.pod.html
    test/markups/README.rdoc
    test/markups/README.rdoc.html
    test/markups/README.rst
    test/markups/README.rst.html
    test/markups/README.rst.txt
    test/markups/README.rst.txt.html
    test/markups/README.textile
    test/markups/README.textile.html
    test/markups/README.txt
    test/markups/README.txt.html
  ]
  # = MANIFEST =

  ## Test files will be grabbed from the file list. Make sure the path glob
  ## matches what you actually use.
  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end

