module GitHub
  module Markup
    class Implementation
      attr_reader :regexp

      def initialize(regexp)
        @regexp = regexp
      end

      def load
        # no-op by default
      end

      def render(content)
        raise NotImplementedError, "subclasses of GitHub::Markup::Implementation must define #render"
      end

      def match?(filename)
        Regexp.compile("\\.(#{regexp})$") =~ filename
      end
    end
  end
end
