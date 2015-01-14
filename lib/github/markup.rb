require "github/markup/command_implementation"
require "github/markup/gem_implementation"

module GitHub
  module Markup
    extend self
    @@markups = []

    def markups
      @@markups
    end

    def preload!
      markups.each do |markup|
        markup.load
      end
    end

    def render(filename, content = nil)
      content ||= File.read(filename)

      if impl = renderer(filename)
        impl.render(content)
      else
        content
      end
    end

    def markup(file, pattern, opts = {}, &block)
      markups << GemImplementation.new(pattern, file, &block)
    end

    def command(command, regexp, &block)
      if File.exist?(file = File.dirname(__FILE__) + "/commands/#{command}")
        command = file
      end

      markups << CommandImplementation.new(regexp, command, &block)
    end

    def can_render?(filename)
      !!renderer(filename)
    end

    def renderer(filename)
      markups.find { |impl|
        impl.match?(filename)
      }
    end

    # Define markups
    markups_rb = File.dirname(__FILE__) + '/markups.rb'
    instance_eval File.read(markups_rb), markups_rb
  end
end
