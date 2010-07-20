require 'rdoc/generators/html_generator'
require 'ostruct'

module GitHub
  module Markup
    class RDoc
      def initialize(content)
        @content = content
      end

      def to_html
        simple_markup = SM::SimpleMarkup.new
        generator = Generators::HyperlinkHtml.new('', OpenStruct.new)
        simple_markup.add_special(/((link:|https?:|mailto:|ftp:|www\.)\S+\w)/, :HYPERLINK)
        simple_markup.add_special(/(((\{.*?\})|\b\S+?)\[\S+?\.\S+?\])/, :TIDYLINK)
        simple_markup.convert(@content, generator)
      end
    end
  end
end
