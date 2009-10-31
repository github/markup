module GitHub
  module Markup
    extend self
    @@markups = {}

    def markup(file, pattern, &block)
      require file.to_s
      add_markup(pattern, &block)
    rescue LoadError
      nil
    end

    def add_markup(regexp, &block)
      @@markups[regexp] = block
    end

    def renderer(filename)
      @@markups.each do |key, value|
        if Regexp.compile("#{key}$") =~ filename
          return value
        end
      end
    end

    def render(filename, content)
      renderer(filename)[content] || content
    end

    # Define markups
    require 'github/markups'
  end
end
