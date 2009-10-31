begin
  require 'open3_detach'
rescue LoadError
  require 'open3'
end

module GitHub
  module Markup
    extend self
    @@markups = {}

    def render(filename, content)
      renderer(filename)[content] || content
    end

    def markup(file, pattern, &block)
      require file.to_s
      add_markup(pattern, &block)
    rescue LoadError
      nil
    end

    def command(command, regexp, &block)
      command = command.to_s
      if !File.exists?(command) && !command.include?('/')
        command = File.dirname(__FILE__) + '/commands/' + command.to_s
      end

      add_markup(regexp) do |content|
        rendered = execute(command, content)
        block ? block.call(rendered) : rendered
      end
    end

    def add_markup(regexp, &block)
      @@markups[regexp] = block
    end

    def renderer(filename)
      @@markups.each do |key, value|
        if Regexp.compile("(#{key})$") =~ filename
          return value
        end
      end
    end

    def execute(command, target)
      out = ''
      Open3.popen3(command) do |stdin, stdout, _|
        stdin.puts target
        stdin.close
        while tmp = stdout.read(1024)
          out << tmp
        end
      end
      out.gsub("\r", '')
    end

    # Define markups
    instance_eval File.read(File.dirname(__FILE__) + '/markups.rb')
  end
end
