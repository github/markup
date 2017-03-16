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

    def render(filename, content = nil)
      content ||= File.read(filename)

      if impl = renderer(filename)
        impl.render(content)
      else
        content
      end
    end
    
    def render_s(symbol, content)
      if content.nil?
        raise ArgumentError, 'Can not render a nil.'
      elsif markups.has_key?(symbol)
        markups[symbol].render(content)
      else
        content
      end
    end
    
    def markup(symbol, file, pattern, opts = {}, &block)
      markup_impl(symbol, GemImplementation.new(pattern, file, &block))
    end
    
    def markup_impl(symbol, impl)
      if markups.has_key?(symbol)
        raise ArgumentError, "The '#{symbol}' symbol is already defined."
      end
      markups[symbol] = impl
    end

    def command(symbol, command, regexp, name, &block)
      if File.exist?(file = File.dirname(__FILE__) + "/commands/#{command}")
        command = file
      end

      markup_impl(symbol, CommandImplementation.new(regexp, command, name, &block))
    end

    def can_render?(filename)
      !!renderer(filename)
    end

    def renderer(filename)
      markup_impls.find { |impl|
        impl.match?(filename)
      }
    end

    # Define markups
    markups_rb = File.dirname(__FILE__) + '/markups.rb'
    instance_eval File.read(markups_rb), markups_rb
  end
end
