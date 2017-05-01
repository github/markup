require "github/markup/implementation"
require "rdoc"
require "rdoc/markup/to_html"

module GitHub
  module Markup
    class RDoc < Implementation
      def initialize
        super([Linguist::Language["RDoc"]])
      end

      def render(content)
        if ::RDoc::VERSION.to_i >= 4
          h = ::RDoc::Markup::ToHtml.new(::RDoc::Options.new)
        else
          h = ::RDoc::Markup::ToHtml.new
        end
        h.convert(content)
      end

      def name
        "rdoc"
      end
    end
  end
end
