if RUBY_PLATFORM == 'java' 
  require "open3"
else
  require "posix-spawn"
end

require "github/markup/implementation"

module GitHub
  module Markup
    class CommandError < RuntimeError
    end

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
      
      if RUBY_PLATFORM == 'java'
        def execute(command, target)
          output = Open3.popen3(*command) do |stdin, stdout, stderr, wait_thr|
            stdin.puts target
            stdin.close
            if wait_thr.value.success?
              stdout.readlines
            else
              raise CommandError.new(stderr.readlines.join('').strip)
            end
          end
          sanitize(output.join(''))
        end
      else
        def execute(command, target)
          spawn = POSIX::Spawn::Child.new(*command, :input => target)
          if spawn.status.success?
            sanitize(spawn.out)
          else
            raise CommandError.new(spawn.err.strip)
          end
          
        end
      end
      
      def sanitize(input)
        input.gsub("\r", '')
      end
      
    end
  end
end
