# encoding: utf-8

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'github/markup'
require 'minitest/autorun'
require 'html/pipeline'
require 'nokogiri'
require 'nokogiri/diff'

def normalize_html(text)
  text.strip
      .gsub(/\s\s+/,' ')
      .gsub(/\p{Pi}|\p{Pf}|&amp;quot;/u,'"')
      .gsub("\u2026",'...')
end

def assert_html_equal(expected, actual, msg = nil)
    assertion = Proc.new do
      expected_doc = Nokogiri::HTML(expected) {|config| config.noblanks}
      actual_doc   = Nokogiri::HTML(actual) {|config| config.noblanks}

      expected_doc.search('//text()').each {|node| node.content = normalize_html node.content}
      actual_doc.search('//text()').each {|node| node.content = normalize_html node.content}

      ignore_changes = {"+" => Regexp.union(/^\s*id=".*"\s*$/), "-" => nil}
      expected_doc.diff(actual_doc) do |change, node|
        if change != ' ' && !node.blank? then
          break unless node.to_html =~ ignore_changes[change]
        end
      end
    end
    assert(assertion.call, msg)
end

class MarkupTest < Minitest::Test
  class MarkupFilter < HTML::Pipeline::Filter
    def call
      filename = context[:filename]
      GitHub::Markup.render(filename, File.read(filename)).strip.force_encoding("utf-8")
    end
  end

  Pipeline = HTML::Pipeline.new [
    MarkupFilter,
    HTML::Pipeline::SanitizationFilter
  ]

  Dir['test/markups/README.*'].each do |readme|
    next if readme =~ /html$/
    markup = readme.split('/').last.gsub(/^README\./, '')

    define_method "test_#{markup}" do
      skip(
        "Skipping MediaWiki test because wikicloth is currently not compatible with JRuby.",
      ) if markup == "mediawiki" && RUBY_PLATFORM == "java"
      source = File.read(readme)
      expected_file = "#{readme}.html"
      expected = File.read(expected_file).rstrip
      actual = Pipeline.to_html(nil, :filename => readme)

      if source != expected
        assert(source != actual, "#{markup} did not render anything")
      end

      diff = IO.popen("diff -u - #{expected_file}", 'r+') do |f|
        f.write actual
        f.close_write
        f.read
      end
      assert_html_equal expected, actual, <<message
#{File.basename expected_file}'s contents are not html equal to output:
#{diff}
message
    end
  end

  def test_knows_what_it_can_and_cannot_render
    assert_equal false, GitHub::Markup.can_render?('README.html', '<h1>Title</h1>')
    assert_equal true, GitHub::Markup.can_render?('README.markdown', '=== Title')
    assert_equal false, GitHub::Markup.can_render?('README.cmd', 'echo 1')
    assert_equal true, GitHub::Markup.can_render?('README.litcoffee', 'Title')
  end

  def test_each_render_has_a_name
    assert_equal "markdown", GitHub::Markup.renderer('README.md', '=== Title').name
    assert_equal "redcloth", GitHub::Markup.renderer('README.textile', '* One').name
    assert_equal "rdoc", GitHub::Markup.renderer('README.rdoc', '* One').name
    assert_equal "org-ruby", GitHub::Markup.renderer('README.org', '* Title').name
    assert_equal "creole", GitHub::Markup.renderer('README.creole', '= Title =').name
    assert_equal "wikicloth", GitHub::Markup.renderer('README.wiki', '<h1>Title</h1>').name
    assert_equal "asciidoctor", GitHub::Markup.renderer('README.adoc', '== Title').name
    assert_equal "restructuredtext", GitHub::Markup.renderer('README.rst', 'Title').name
    assert_equal "pod", GitHub::Markup.renderer('README.pod', '=head1').name
    assert_equal "pod6", GitHub::Markup.renderer('README.pod6', '=begin pod').name
  end

  def test_rendering_by_symbol
    markup = '`test`'
    result = /<p><code>test<\/code><\/p>/
    assert_match result, GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, markup).strip
    assert_match result, GitHub::Markup.render_s(GitHub::Markups::MARKUP_ASCIIDOC, markup).split.join
  end

  def test_raises_error_if_command_exits_non_zero
    GitHub::Markup.command(:doesntmatter, 'test/fixtures/fail.sh', /fail/, ['Java'], 'fail')
    assert GitHub::Markup.can_render?('README.java', 'stop swallowing errors')
    begin
      GitHub::Markup.render('README.java', "stop swallowing errors", symlink: false)
    rescue GitHub::Markup::CommandError => e
      assert_equal "failure message", e.message
    else
      fail "an exception was expected but was not raised"
    end
  end

  def test_preserve_markup
    content = "Noël"
    assert_equal content.encoding.name, GitHub::Markup.render('Foo.rst', content).encoding.name
  end

  def test_commonmarker_options
    assert_equal(
      "<p>hello <!-- raw HTML omitted --> world</p>\n",
      GitHub::Markup.render("test.md", "hello <bad> world"),
    )
    assert_equal(
      "<p>hello <bad> world</p>\n",
      GitHub::Markup.render(
        "test.md",
        "hello <bad> world",
        options: { commonmarker_opts: [:UNSAFE] },
      ),
    )

    assert_equal(
      "<p>hello <!-- raw HTML omitted --> world</p>\n",
      GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, "hello <bad> world"),
    )
    assert_equal(
      "<p>hello <bad> world</p>\n",
      GitHub::Markup.render_s(
        GitHub::Markups::MARKUP_MARKDOWN,
        "hello <bad> world",
        options: { commonmarker_opts: [:UNSAFE] },
      ),
    )

    assert_equal(
      "&lt;style>.red{color: red;}&lt;/style>\n",
      GitHub::Markup.render(
        "test.md",
        "<style>.red{color: red;}</style>",
        options: { commonmarker_opts: [:UNSAFE] },
      ),
    )
    assert_equal(
      "<style>.red{color: red;}</style>\n",
      GitHub::Markup.render(
        "test.md",
        "<style>.red{color: red;}</style>",
        options: {
          commonmarker_opts: [:UNSAFE],
          commonmarker_exts: [:autolink, :table, :strikethrough],
        },
      ),
    )

    assert_equal(
      "&lt;style>.red{color: red;}&lt;/style>\n",
      GitHub::Markup.render_s(
        GitHub::Markups::MARKUP_MARKDOWN,
        "<style>.red{color: red;}</style>",
        options: { commonmarker_opts: [:UNSAFE] },
      ),
    )
    assert_equal(
      "<style>.red{color: red;}</style>\n",
      GitHub::Markup.render_s(
        GitHub::Markups::MARKUP_MARKDOWN,
        "<style>.red{color: red;}</style>",
        options: {
          commonmarker_opts: [:UNSAFE],
          commonmarker_exts: [:autolink, :table, :strikethrough],
        },
      ),
    )
  end
end
