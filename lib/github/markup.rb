begin
  require 'open3_detach'
rescue LoadError
  require 'open3'
end

module GitHub
  module Markup
    extend self
    @@markups = {}
    @@deferred_markups = []

    def preload!
      @@deferred_markups.each do |loader|
        loader.call
      end
      @@deferred_markups = []
    end

    def render(filename, content = nil)
      content ||= File.read(filename)

      if proc = renderer(filename)
        proc[content]
      else
        content
      end
    end

    def markup(file, pattern, &block)
      loader = proc do
        require file.to_s
        add_markup(pattern, &block)
      end
      @@deferred_markups << loader
      add_markup pattern do |*args|
        @@deferred_markups.delete(loader)
        loader.call
        block.call(*args)
      end
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
    rescue Errno::ENOENT
      ""
    end

    # Define markups
    markups_rb = File.dirname(__FILE__) + '/markups.rb'
    instance_eval File.read(markups_rb), markups_rb
  end
end
