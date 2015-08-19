module GitHub
  module Markup
    class Implementation
      attr_reader :languages

      def initialize(languages)
        @languages = languages
      end

      def load
        # no-op by default
      end

      def render(content)
        raise NotImplementedError, "subclasses of GitHub::Markup::Implementation must define #render"
      end

      def match?(language)
        languages.include? language
      end
    end
  end
end
