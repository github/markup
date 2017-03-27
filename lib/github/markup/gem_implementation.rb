require "github/markup/implementation"

module GitHub
  module Markup
    class GemImplementation < Implementation
      attr_reader :gem_name, :renderer

      def initialize(languages, gem_name, &renderer)
        super languages
        @gem_name = gem_name.to_s
        @renderer = renderer
      end

      def load
        return if @loaded
        require gem_name
        @loaded = true
      end

      def render(content)
        load
        renderer.call(content)
      end

      def name
        gem_name
      end
    end
  end
end
