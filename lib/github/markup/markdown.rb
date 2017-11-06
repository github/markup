require "github/markup/implementation"

module GitHub
  module Markup
    class Markdown < Implementation
      MARKDOWN_GEMS = {
        "commonmarker" => proc { |content|
          CommonMarker.render_html(content, :GITHUB_PRE_LANG, [:tagfilter, :autolink, :table, :strikethrough])
        },
        "github/markdown" => proc { |content|
          GitHub::Markdown.render(content)
        },
        "redcarpet" => proc { |content|
          Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(content)
        },
        "rdiscount" => proc { |content|
          RDiscount.new(content).to_html
        },
        "maruku" => proc { |content|
          Maruku.new(content).to_html
        },
        "kramdown" => proc { |content|
          Kramdown::Document.new(content).to_html
        },
        "bluecloth" => proc { |content|
          BlueCloth.new(content).to_html
        },
      }

      def initialize
        super(
          /md|rmd|mkdn?|mkd|mdwn|mdown|markdown|litcoffee/i,
          ["Markdown", "RMarkdown", "Literate CoffeeScript"])
      end

      def load
        return if @renderer
        MARKDOWN_GEMS.each do |gem_name, renderer|
          if try_require(gem_name)
            @renderer = renderer
            return
          end
        end
        raise LoadError, "no suitable markdown gem found"
      end

      def render(filename, content)
        load
        @renderer.call(content)
      end

      def name
        "markdown"
      end

    private
      def try_require(file)
        require file
        true
      rescue LoadError
        false
      end
    end
  end
end
