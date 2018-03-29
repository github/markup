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
    MARKUP_POD6 = :pod6
    MARKUP_RDOC = :rdoc
    MARKUP_RST = :rst
    MARKUP_TEXTILE = :textile
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
      markup_impls.each do |markup|
        markup.load
      end
    end

    def render(filename, content, symlink = false)
      if impl = renderer(filename, content, symlink)
        impl.render(filename, content)
      else
        content
      end
    end
    
    def render_s(symbol, content)
      if content.nil?
        raise ArgumentError, 'Can not render a nil.'
      elsif markups.has_key?(symbol)
        markups[symbol].render(nil, content)
      else
        content
      end
    end

    def markup(symbol, gem_name, regexp, languages, opts = {}, &block)
      markup_impl(symbol, GemImplementation.new(regexp, languages, gem_name, &block))
    end
    
    def markup_impl(symbol, impl)
      if markups.has_key?(symbol)
        raise ArgumentError, "The '#{symbol}' symbol is already defined."
      end
      markups[symbol] = impl
    end

    def command(symbol, command, regexp, languages, name, &block)
      if File.exist?(file = File.dirname(__FILE__) + "/commands/#{command}")
        command = file
      end

      markup_impl(symbol, CommandImplementation.new(regexp, languages, command, name, &block))
    end

    def can_render?(filename, content, symlink = false)
      !!renderer(filename, content, symlink)
    end

    def renderer(filename, content, symlink = false)
      language = language(filename, content, symlink)
      markup_impls.find { |impl|
        impl.match?(filename, language)
      }
    end

    def language(filename, content, symlink = false)
      if defined?(::Linguist)
        blob = Linguist::Blob.new(filename, content, symlink: symlink)
        return Linguist.detect(blob, allow_empty: true)
      end
    end

    # Define markups
    markups_rb = File.dirname(__FILE__) + '/markups.rb'
    instance_eval File.read(markups_rb), markups_rb
  end
end
