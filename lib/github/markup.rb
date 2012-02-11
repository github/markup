begin
  require 'open3_detach'
rescue LoadError
  require 'open3'
end

module GitHub
  module Markup
    extend self
    @@markups = {}

    def render(filename, content = nil)
      content ||= File.read(filename)

      if proc = renderer(filename)
        proc[content]
      else
        content
      end
    end

    def markup(file, pattern, &block)
      require file.to_s
      add_markup(pattern, &block)
      true
    rescue LoadError
      false
    end

    def command(command, regexp, &block)
      command = command.to_s

      if File.exists?(file = File.dirname(__FILE__) + "/commands/#{command}")
        command = file
      end

      add_markup(regexp) do |content|
        rendered = execute(command, content)
        rendered = rendered.to_s.empty? ? content : rendered

        if block && block.arity == 2
          # If the block takes two arguments, pass new content and old
          # content.
          block.call(rendered, content)
        elsif block
          # One argument is just the new content.
          block.call(rendered)
        else
          # No block? No problem!
          rendered
        end
      end
    end

    def add_markup(regexp, &block)
      @@markups[regexp] = block
    end

    def can_render?(filename)
      !!renderer(filename)
    end

    def renderer(filename)
      @@markups.each do |key, value|
        if Regexp.compile("\\.(#{key})$") =~ filename
          return value
        end
      end
      nil
    end

    def renderer_name(filename)
      @@markups.each do |key, value|
        if Regexp.compile("\\.(#{key})$") =~ filename
          return key
        end
      end
      nil
    end

    def execute(command, target)
      out = ''
      Open3.popen3(command) do |stdin, stdout, _|
        stdin.puts target
        stdin.close
        out = stdout.read
      end
      out.gsub("\r", '')
    rescue Errno::EPIPE
      ""
    end

    # Define markups
    instance_eval File.read(File.dirname(__FILE__) + '/markups.rb')
  end
end
