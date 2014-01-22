require "rdoc"
require "rdoc/markup/to_html"

module GitHub
  module Markup
    class RDoc
      def initialize(content)
        @content = content
      end

      def to_html
        if ::RDoc::VERSION.to_i >= 4
          h = ::RDoc::Markup::ToHtml.new(::RDoc::Options.new)
        else
          h = ::RDoc::Markup::ToHtml.new
        end
        h.convert(@content)
      end
    end
  end
end
