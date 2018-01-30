module GitHub
  module Markup
    class Implementation
      attr_reader :regexp
      attr_reader :languages

      def initialize(regexp, languages)
        @regexp = regexp

        if defined?(::Linguist)
          @languages = languages.map {|l| Linguist::Language[l]}
        end
      end

      def load
        # no-op by default
      end

      def render(filename, content)
        raise NotImplementedError, "subclasses of GitHub::Markup::Implementation must define #render"
      end

      def match?(filename, language)
        if defined?(::Linguist)
          languages.include? language
        else
          file_ext_regexp =~ filename
        end
      end

      private

      def file_ext_regexp
        @file_ext_regexp ||= /\.(#{regexp})\z/
      end
    end
  end
end
