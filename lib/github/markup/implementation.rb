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
        file_ext_regexp =~ filename
      end

    private
      def file_ext_regexp
        @file_ext_regexp ||= /\.(#{regexp})\z/
      end
    end
  end
end
