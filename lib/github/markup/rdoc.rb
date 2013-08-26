require "rdoc"
require "rdoc/markup/to_html"

module GitHub
  module Markup
    class RDoc
      def initialize(content)
        @content = content
      end

      def to_html
        if Gem::Version.new(::RDoc::VERSION) < Gem::Version.new('4.0.0')
          h = ::RDoc::Markup::ToHtml.new
        else
          h = ::RDoc::Markup::ToHtml.new(::RDoc::Options.new)
        end
        h.convert(@content)
      end
    end
  end
end
