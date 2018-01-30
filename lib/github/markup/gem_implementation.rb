require "github/markup/implementation"

module GitHub
  module Markup
    class GemImplementation < Implementation
      attr_reader :gem_name, :renderer

      def initialize(regexp, languages, gem_name, &renderer)
        super(regexp, languages)
        @gem_name = gem_name.to_s
        @renderer = renderer
      end

      def load
        return if @loaded
        require gem_name
        @loaded = true
      end

      def render(filename, content)
        load
        renderer.call(filename, content)
      end

      def name
        gem_name
      end
    end
  end
end
