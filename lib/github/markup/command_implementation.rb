require "posix-spawn"
require "github/markup/implementation"

module GitHub
  module Markup
    CommandError = Class.new(Exception)

    class CommandImplementation < Implementation
      attr_reader :command, :block

      def initialize(regexp, command, &block)
        super regexp
        @command = command.to_s
        @block = block
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
          spawn.out.gsub("\r", '')
        else
          raise CommandError.new(spawn.err.strip)
        end
      end
    end
  end
end
