require 'rdiscount'
require 'redcloth'

module GitHub
  module Markup
    extend self
    @@markups = {}

    def markups
      @@markups
    end

    def add_markup(regexp, &block)
      markups[regexp] = block
    end

    def renderer(filename)
      @@markups.each do |key, value|
        if Regexp.compile("#{key}$") =~ filename
          return value
        end
      end
    end

    def render(filename, content)
      renderer(filename)[content]
    end
  end
end

begin
  require 'rdiscount'
  GitHub::Markup.add_markup(/md|mkdn?|markdown/) do |content|
    Markdown.new(content).to_html
  end
rescue LoadError
  nil
end

begin
  require 'redcloth'
  GitHub::Markup.add_markup(/textile/) do |content|
    RedCloth.new(content).to_html
  end
rescue LoadError
  nil
end
