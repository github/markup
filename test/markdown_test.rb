$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require_relative "test_helper"
require "github/markup"
require "commonmarker"
require "minitest/autorun"
require "nokogiri"

class MarkdownTest < Minitest::Test
  include ConstantStubbing

  def test_uses_legacy_api_when_modern_interface_is_unavailable
    legacy = Module.new
    legacy.define_singleton_method(:render_html) do |content, _options, _extensions|
      "<p>legacy #{content}</p>\n"
    end

    with_stub_const("Commonmarker", Module.new) do
      with_stub_const("CommonMarker", legacy) do
        actual = GitHub::Markup::Markdown::MARKDOWN_GEMS.fetch("commonmarker").call("payload")
        assert_equal "<p>legacy payload</p>\n", actual
      end
    end
  end

  def test_renders_through_both_public_entry_points
    assert_equal "<p>hello</p>\n", GitHub::Markup.render("raw.md", "hello")
    assert_equal "<p>hello</p>\n", GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, "hello")
  end

  def test_preserves_code_language
    document = Nokogiri::HTML.fragment(GitHub::Markup.render("raw.md", "```ruby\nputs 1\n```\n"))
    assert_equal "ruby", document.at_css("pre")["lang"]
    assert_equal "puts 1\n", document.at_css("code").text
  end

  def test_preserves_unsafe_html_and_footnotes_without_mutating_frozen_options
    options = {commonmarker_opts: [:UNSAFE, :FOOTNOTES].freeze}.freeze
    html = GitHub::Markup.render("raw.md", "hello <b>world</b>[^1]\n\n[^1]: note\n", options: options)
    document = Nokogiri::HTML.fragment(html)

    assert_equal "world", document.at_css("b").text
    assert_equal "1", document.at_css("sup a").text
    assert_includes document.at_css("li p").text, "note"
  end

  def test_nobreaks_preserves_the_installed_backends_behavior
    actual = GitHub::Markup.render("raw.md", "first\nsecond\n", options: {commonmarker_opts: [:NOBREAKS]})
    expected = legacy_commonmarker? ? "<p>first second</p>\n" : "<p>first\nsecond</p>\n"
    assert_equal expected, actual
  end

  def test_conflicting_break_flags_preserve_the_installed_backends_precedence
    actual = GitHub::Markup.render("raw.md", "first\nsecond\n", options: {commonmarker_opts: [:HARDBREAKS, :NOBREAKS]})
    expected = legacy_commonmarker? ? "<p>first<br />\nsecond</p>\n" : "<p>first\nsecond</p>\n"
    assert_equal expected, actual

    reverse = GitHub::Markup.render("raw.md", "first\nsecond\n", options: {commonmarker_opts: [:NOBREAKS, :HARDBREAKS]})
    assert_equal "<p>first<br />\nsecond</p>\n", reverse
  end

  def test_table_style_option_and_frozen_extension_list
    content = "| left | right |\n| :--- | ---: |\n| a | b |\n"
    options = {commonmarker_opts: [:TABLE_PREFER_STYLE_ATTRIBUTES], commonmarker_exts: [:table].freeze}
    document = Nokogiri::HTML.fragment(GitHub::Markup.render("raw.md", content, options: options))

    assert_equal ["left", "right"], document.css("th").map(&:text)
    attribute = legacy_commonmarker? ? "style" : "align"
    expected = legacy_commonmarker? ? "text-align: left" : "left"
    assert_equal expected, document.at_css("th")[attribute]
  end

  def test_double_tilde_option_preserves_the_installed_backends_behavior
    options = {commonmarker_opts: [:STRIKETHROUGH_DOUBLE_TILDE], commonmarker_exts: [:strikethrough]}
    actual = GitHub::Markup.render("raw.md", "~one~ ~~two~~\n", options: options)
    expected = legacy_commonmarker? ? "<p>~one~ <del>two</del></p>\n" : "<p><del>one</del> <del>two</del></p>\n"
    assert_equal expected, actual
  end

  def test_extensions_follow_the_installed_parsers_capabilities
    options = {commonmarker_exts: [:header_ids]}
    if legacy_commonmarker?
      error = assert_raises(ArgumentError) { GitHub::Markup.render("raw.md", "# Title", options: options) }
      assert_match(/extension header_ids not found/, error.message)
    else
      document = Nokogiri::HTML.fragment(GitHub::Markup.render("raw.md", "# Title", options: options))
      assert_equal "title", document.at_css("a[id]")["id"]
    end
  end

  private

  def legacy_commonmarker?
    Gem.loaded_specs.fetch("commonmarker").version < Gem::Version.new("1")
  end
end
