require "github/markup/implementation"

module GitHub
  module Markup
    class Markdown < Implementation
      MARKDOWN_GEMS = {
        "commonmarker" => proc { |content, options: {}|
          commonmarker_opts = [:GITHUB_PRE_LANG].concat(options.fetch(:commonmarker_opts, []))
          commonmarker_exts = options.fetch(:commonmarker_exts, [:tagfilter, :autolink, :table, :strikethrough])
          CommonMarker.render_html(content, commonmarker_opts, commonmarker_exts)
        },
        "github/markdown" => proc { |content, options: {}|
          GitHub::Markdown.render(content)
        },
        "redcarpet" => proc { |content, options: {}|
          Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(options), fenced_code_blocks: true).render(content)
        },
        "rdiscount" => proc { |content, options: {}|
          RDiscount.new(content).to_html
        },
        "maruku" => proc { |content, options: {}|
          Maruku.new(content).to_html
        },
        "kramdown" => proc { |content, options: {}|
          Kramdown::Document.new(content).to_html
        },
        "bluecloth" => proc { |content, options: {}|
          BlueCloth.new(content).to_html
        },
      }

      def initialize
        super(
          /md|mkdn?|mdwn|mdown|markdown|litcoffee/i,
          ["Markdown", "Literate CoffeeScript"])
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

      def render(filename, content, options: {})
        load
        @renderer.call(content, options: options)
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
