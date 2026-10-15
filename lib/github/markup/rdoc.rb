require "github/markup/implementation"
require "rdoc"
require "rdoc/markup/to_html"

module GitHub
  module Markup
    class RDoc < Implementation
      def initialize
        super(/rdoc/, ["RDoc"])
      end

      def render(filename, content, options: {})
        # RDoc 4-7 require positional Options; RDoc 8 uses keyword options.
        # Each run covers only the installed RDoc's branch; CI tests both.
        # :nocov:
        if (4...8).cover?(::RDoc::VERSION.to_i)
          h = ::RDoc::Markup::ToHtml.new(::RDoc::Options.new)
        else
          h = ::RDoc::Markup::ToHtml.new
        end
        # :nocov:
        h.convert(content)
      end

      def name
        "rdoc"
      end
    end
  end
end
