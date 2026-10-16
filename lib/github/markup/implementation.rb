module GitHub
  module Markup
    class Implementation
      attr_reader :regexp
      attr_reader :languages

      def initialize(regexp, languages)
        @regexp = regexp

        if defined?(::Linguist)
          @languages = languages.map do |l|
            lang = Linguist::Language[l]
            raise "no match for language #{l.inspect}" if lang.nil?
            lang
          end
        end
      end

      def load
        # no-op by default
      end

      def render(filename, content, options: {})
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
        # Use regexp.source so an /i flag on this pattern applies to the
        # extension itself. Interpolating a Regexp object embeds (?-mix:),
        # which would keep .MD from matching /md/.
        @file_ext_regexp ||= /\.(?:#{regexp.source})\z/i
      end
    end
  end
end
