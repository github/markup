require "github/markup/implementation"

module GitHub
  module Markup
    class Markdown < Implementation
      MARKDOWN_GEMS = {
        "commonmarker" => proc { |content, options: {}|
          legacy_opts = options.fetch(:commonmarker_opts, [])
          legacy_exts = options.fetch(
            :commonmarker_exts,
            [:tagfilter, :autolink, :table, :strikethrough],
          )

          parse_options = {}
          # commonmarker 2.x changes several render defaults that diverge from cmark-gfm 0.x:
          #   - hardbreaks defaults to true in 2.x but was false in 0.x.
          #   - escaped_char_spans defaults to true in 2.x and wraps backslash-escaped chars in
          #     <span data-escaped-char>; 0.x emitted bare characters.
          #   - gfm_quirks defaults to false in 2.x; 0.x (cmark-gfm) always had the quirk on,
          #     which collapses ****foo**** to <strong>foo</strong> instead of nesting.
          #   - github_pre_lang defaults to true in 2.x; set explicitly to match the legacy contract.
          render_options = {
            github_pre_lang: true,
            hardbreaks: false,
            escaped_char_spans: false,
            gfm_quirks: true,
          }
          extension_options = {}

          legacy_opts.each do |opt|
            case opt
            when :DEFAULT then nil
            when :SOURCEPOS then render_options[:sourcepos] = true
            when :HARDBREAKS then render_options[:hardbreaks] = true
            when :NOBREAKS then render_options[:hardbreaks] = false
            when :SMART then parse_options[:smart] = true
            when :GITHUB_PRE_LANG then render_options[:github_pre_lang] = true
            when :UNSAFE then render_options[:unsafe] = true
            when :FOOTNOTES then extension_options[:footnotes] = true
            when :FULL_INFO_STRING then render_options[:full_info_string] = true
              # The legacy options below existed in cmark-gfm 0.x but have no direct commonmarker
              # 2.x equivalent. Accept them so existing callers don't break, but they have no effect:
              #   :VALIDATE_UTF8 / :LIBERAL_HTML_TAG - enforced at the Rust type layer in 2.x.
              #   :TABLE_PREFER_STYLE_ATTRIBUTES     - no 2.x render knob for inline table styles.
              #   :STRIKETHROUGH_DOUBLE_TILDE        - 2.x always accepts both single and double tilde.
            when :VALIDATE_UTF8, :LIBERAL_HTML_TAG,
                 :TABLE_PREFER_STYLE_ATTRIBUTES, :STRIKETHROUGH_DOUBLE_TILDE
              nil
            else
              raise ArgumentError, "unknown commonmarker option: #{opt.inspect}"
            end
          end

          legacy_exts.each do |ext|
            case ext
            when :strikethrough, :tagfilter, :autolink, :table, :tasklist,
                 :shortcodes, :footnotes, :multiline_block_quotes,
                 :math_dollars, :math_code, :wikilinks_title_after_pipe,
                 :wikilinks_title_before_pipe, :underline, :subscript, :spoiler,
                 :greentext, :alerts, :description_lists
              extension_options[ext] = true
            when :header_ids
              # header_ids takes a string prefix in 2.x rather than a boolean. The legacy contract
              # only passed it as a symbol, so use an empty prefix to enable anchor generation.
              extension_options[:header_ids] = ""
            else
              raise ArgumentError, "unknown commonmarker extension: #{ext.inspect}"
            end
          end

          # Several extensions (tagfilter, autolink, table, strikethrough, tasklist, shortcodes)
          # are enabled by default in commonmarker 2.x but were strictly opt-in in 0.x. Explicitly
          # disable any extension the caller did not request so behavior matches the legacy contract.
          [:strikethrough, :tagfilter, :autolink, :table, :tasklist, :shortcodes].each do |ext|
            extension_options[ext] = false unless extension_options[ext]
          end

          # header_ids is enabled by default in commonmarker 2.x (it injects anchor tags inside
          # every heading). The legacy 0.x wrapper never enabled it implicitly, so disable it
          # unless the caller explicitly requested it.
          extension_options[:header_ids] = nil unless extension_options.key?(:header_ids)

          Commonmarker.to_html(
            content,
            options: {
              parse: parse_options,
              render: render_options,
              extension: extension_options,
            },
            plugins: {syntax_highlighter: nil},
          )
        },
        "github/markdown" => proc { |content, options: {}|
          GitHub::Markdown.render(content)
        },
        "redcarpet" => proc { |content, options: {}|
          Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(content)
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
          /md|mkdn?|mdwn|mdown|markdown|mdx|litcoffee/i,
          ["Markdown", "MDX", "Literate CoffeeScript"])
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
