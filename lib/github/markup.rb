begin
  require "linguist"
rescue LoadError
  # Rely on extensions instead.
end

require "github/markup/command_implementation"
require "github/markup/gem_implementation"

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
    MARKUP_MANPAGE = :manpage
    MARKUP_POD6 = :pod6
  end

  module Markup
    extend self

    @@markups = {}

    def markups
      @@markups
    end

    def markup_impls
      markups.values
    end

    def preload!
      markup_impls.each(&:load)
    end

    def render(filename, content, symlink: false, options: {})
      if (impl = renderer(filename, content, symlink: symlink))
        impl.render(filename, content, options: options)
      else
        content
      end
    end

    def render_s(symbol, content, options: {})
      raise ArgumentError, 'Can not render a nil.' if content.nil?

      if markups.key?(symbol)
        markups[symbol].render(nil, content, options: options)
      else
        content
      end
    end

    def markup(symbol, gem_name, regexp, languages, opts = {}, &block)
      impl = GemImplementation.new(regexp, languages, gem_name, &block)
      markup_impl(symbol, impl)
    end

    def markup_impl(symbol, impl)
      if markups.key?(symbol)
        raise ArgumentError, "The '#{symbol}' symbol is already defined."
      end
      markups[symbol] = impl
    end

    def command(symbol, command, regexp, languages, name, &block)
      if File.exist?(file = File.dirname(__FILE__) + "/commands/#{command}")
        command = file
      end

      impl = CommandImplementation.new(regexp, languages, command, name, &block)
      markup_impl(symbol, impl)
    end

    def can_render?(filename, content, symlink: false)
      renderer(filename, content, symlink: symlink) != nil
    end

    def renderer(filename, content, symlink: false)
      language = language(filename, content, symlink: symlink)
      markup_impls.find do |impl|
        impl.match?(filename, language)
      end
    end

    def language(filename, content, symlink: false)
      return unless defined?(::Linguist)

      blob = Linguist::Blob.new(filename, content, symlink: symlink)
      Linguist.detect(blob, allow_empty: true)
    end

    # Define markups
    markups_rb = File.dirname(__FILE__) + '/markups.rb'
    instance_eval File.read(markups_rb), markups_rb
  end
end
