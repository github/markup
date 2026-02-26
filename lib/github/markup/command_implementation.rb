require "open3"
require "github/markup/implementation"


module GitHub
  module Markup
    class CommandError < RuntimeError
    end

    class CommandImplementation < Implementation
      attr_reader :command, :block, :name

      def initialize(regexp, languages, command, name, &block)
        super(regexp, languages)
        @command = command.to_s
        @block = block
        @name = name
      end

      def render(filename, content, options: {})
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
        # capture3 blocks until both buffers are written to and the process terminates, but
        # it won't allow either buffer to fill up
        stdout, stderr, status = Open3.capture3(*command, stdin_data: target)

        raise CommandError.new(stderr) unless status.success?
        sanitize(stdout, target.encoding)
      end

      def sanitize(input, encoding)
        input.gsub("\r", '').force_encoding(encoding)
      end

    end
  end
end
