require "github/markup/implementation"

module GitHub
  module Markup
    class GemImplementation < Implementation
      attr_reader :gem_name, :renderer

      def initialize(regexp, languages, gem_name, mutable_string_literals: false, &renderer)
        super(regexp, languages)
        @gem_name = gem_name.to_s
        @mutable_string_literals = mutable_string_literals
        @renderer = renderer
      end

      def load
        return if defined?(@loaded) && @loaded
        if @mutable_string_literals
          with_mutable_string_literals { require gem_name }
        else
          require gem_name
        end
        @loaded = true
      end

      def render(filename, content, options: {})
        load
        renderer.call(filename, content, options: options)
      end

      def name
        gem_name
      end

      private

      # Some renderer gems modify string literals in place. When string literals
      # are frozen by default (--enable=frozen-string-literal, or a future Ruby),
      # compile those gems with mutable literals so they keep working. Otherwise
      # leave the compile options alone: Ruby can't restore its default
      # "chilled" state once it has been changed.
      def with_mutable_string_literals
        # :nocov:
        return yield unless defined?(RubyVM::InstructionSequence)
        # :nocov:
        options = RubyVM::InstructionSequence.compile_option
        return yield unless options[:frozen_string_literal]
        begin
          RubyVM::InstructionSequence.compile_option = options.merge(frozen_string_literal: false)
          yield
        ensure
          RubyVM::InstructionSequence.compile_option = options
        end
      end
    end
  end
end
