require "posix-spawn"
require "github/markup/implementation"

module GitHub
  module Markup
    class CommandError < RuntimeError
    end

    class CommandImplementation < Implementation
      attr_reader :command, :block, :name

      def initialize(regexp, command, name, &block)
        super regexp
        @command = command.to_s
        @block = block
        @name = name
      end

      def render(content)
        rendered = execute(command, content)
        rendered = rendered.to_s.empty? ? content : rendered
        call_block(rendered, content)
      end

    private
      def call_block(rendered, content)
        if block && block.arity == 2
          block.call(rendered, content)
        elsif block
          block.call(rendered)
        else
          rendered
        end
      end

      def execute(command, target)
        spawn = POSIX::Spawn::Child.new(*command, :input => target)
        if spawn.status.success?
          spawn.out.gsub("\r", '').force_encoding(target.encoding)
        else
          raise CommandError.new(spawn.err.strip)
        end
      end
    end
  end
end
