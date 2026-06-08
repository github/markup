# encoding: utf-8

# Exercises code paths the original markup_test.rb does not reach:
# - The six fallback markdown gem procs (github/markdown, redcarpet,
#   rdiscount, maruku, kramdown, bluecloth) executed against stubbed constants
# - The LoadError ("no suitable markdown gem found") raised when no gem is available
# - try_require's rescue clause
# - Implementation#render's NotImplementedError default
# - Implementation#match? without Linguist (and the lazy regexp memoization)
# - GitHub::Markup.markup_impl's duplicate-symbol guard
# - GitHub::Markup.render falling through to the raw content
# - GitHub::Markup.render_s with an unknown symbol and with nil content
# - GitHub::Markup.preload!
# - GitHub::Markup.language returning nil without Linguist
# - CommandImplementation block-arity branches (arity 1 vs 2)

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require_relative 'test_helper'
require 'github-markup'
require 'github/markup'
require 'minitest/autorun'

class CoverageTest < Minitest::Test
  def test_version_constant_is_defined
    assert_kind_of String, GitHub::Markup::VERSION
    assert_equal GitHub::Markup::VERSION, GitHub::Markup::Version
  end

  # --- markdown.rb fallback procs ----------------------------------------

  def test_github_markdown_proc_uses_github_markdown_render
    with_stub_const("GitHub::Markdown", fake_renderer_module(:render)) do
      result = GitHub::Markup::Markdown::MARKDOWN_GEMS.fetch("github/markdown").call("hi")
      assert_equal "github_markdown:hi", result
    end
  end

  def test_redcarpet_proc_renders_via_redcarpet
    fake_html = Class.new
    fake_md = Class.new do
      def initialize(*); end
      def render(content); "redcarpet:#{content}"; end
    end
    fake_module = Module.new
    fake_module.const_set(:Render, Module.new.tap { |m| m.const_set(:HTML, fake_html) })
    fake_module.const_set(:Markdown, fake_md)
    with_stub_const("Redcarpet", fake_module) do
      result = GitHub::Markup::Markdown::MARKDOWN_GEMS.fetch("redcarpet").call("hi")
      assert_equal "redcarpet:hi", result
    end
  end

  def test_rdiscount_proc_renders_via_rdiscount
    with_stub_const("RDiscount", instance_renderer_class(:to_html, prefix: "rdiscount")) do
      result = GitHub::Markup::Markdown::MARKDOWN_GEMS.fetch("rdiscount").call("hi")
      assert_equal "rdiscount:hi", result
    end
  end

  def test_maruku_proc_renders_via_maruku
    with_stub_const("Maruku", instance_renderer_class(:to_html, prefix: "maruku")) do
      result = GitHub::Markup::Markdown::MARKDOWN_GEMS.fetch("maruku").call("hi")
      assert_equal "maruku:hi", result
    end
  end

  def test_kramdown_proc_renders_via_kramdown_document
    fake_doc = instance_renderer_class(:to_html, prefix: "kramdown")
    fake_module = Module.new.tap { |m| m.const_set(:Document, fake_doc) }
    with_stub_const("Kramdown", fake_module) do
      result = GitHub::Markup::Markdown::MARKDOWN_GEMS.fetch("kramdown").call("hi")
      assert_equal "kramdown:hi", result
    end
  end

  def test_bluecloth_proc_renders_via_bluecloth
    with_stub_const("BlueCloth", instance_renderer_class(:to_html, prefix: "bluecloth")) do
      result = GitHub::Markup::Markdown::MARKDOWN_GEMS.fetch("bluecloth").call("hi")
      assert_equal "bluecloth:hi", result
    end
  end

  # --- markdown.rb load failure and try_require rescue --------------------

  def test_markdown_load_raises_loaderror_when_no_gem_is_available
    md = GitHub::Markup::Markdown.new
    def md.try_require(_); false; end
    assert_raises(LoadError) { md.load }
  end

  def test_try_require_returns_false_for_missing_gem
    md = GitHub::Markup::Markdown.new
    refute md.send(:try_require, "github_markup_definitely_not_a_real_gem_#{Time.now.to_i}")
  end

  # --- rdoc.rb legacy version branch --------------------------------------
  # The `RDoc::VERSION < 4` branch in rdoc.rb is marked :nocov: in source
  # because the modern RDoc::Markup::ToHtml constructor requires Options
  # and the legacy zero-arg form has been broken since RDoc 4 (2013).

  # --- implementation.rb default render and Linguist-less match? ---------

  def test_base_implementation_render_raises_not_implemented_error
    impl = GitHub::Markup::Implementation.new(/foo/, [])
    assert_raises(NotImplementedError) { impl.render("README.foo", "anything") }
  end

  def test_match_uses_filename_extension_when_linguist_is_absent
    impl_class = Class.new(GitHub::Markup::Implementation) do
      def initialize; super(/md|markdown/, []); end
    end
    impl = impl_class.new
    without_linguist do
      assert impl.match?("README.md", nil)
      # call again to cover the memoization branch in file_ext_regexp
      assert impl.match?("README.markdown", nil)
      refute impl.match?("README.txt", nil)
    end
  end

  # --- markup.rb registration guard, render fallthroughs, preload! -------

  def test_markup_impl_raises_when_symbol_already_registered
    err = assert_raises(ArgumentError) do
      GitHub::Markup.markup_impl(
        ::GitHub::Markups::MARKUP_MARKDOWN,
        GitHub::Markup::Markdown.new
      )
    end
    assert_match(/already defined/, err.message)
  end

  def test_render_returns_content_when_no_implementation_matches
    raw = "no extension match here"
    assert_equal raw, GitHub::Markup.render("README.unknown_ext_xyz", raw)
  end

  def test_render_s_returns_content_when_symbol_is_unknown
    raw = "passthrough body"
    assert_equal raw, GitHub::Markup.render_s(:not_a_real_markup_symbol, raw)
  end

  def test_render_s_raises_on_nil_content
    assert_raises(ArgumentError) do
      GitHub::Markup.render_s(::GitHub::Markups::MARKUP_MARKDOWN, nil)
    end
  end

  def test_preload_calls_load_on_every_implementation
    GitHub::Markup.preload!
    # If preload! succeeded, every markup_impl reports a non-nil renderer or completes its load step.
    GitHub::Markup.markup_impls.each do |impl|
      assert_respond_to impl, :load
    end
  end

  def test_language_returns_nil_without_linguist
    without_linguist do
      assert_nil GitHub::Markup.language("README.md", "anything")
    end
  end

  # --- implementation.rb: Linguist-absent constructor + invalid-language raise

  def test_implementation_initializes_without_linguist
    without_linguist do
      # Forces the else branch of `if defined?(::Linguist)` in initialize
      impl = GitHub::Markup::Implementation.new(/foo/, ["AnythingGoesWithoutLinguist"])
      assert_nil impl.languages
      refute impl.match?("README.bar", nil)
    end
  end

  def test_implementation_raises_for_unknown_linguist_language
    err = assert_raises(RuntimeError) do
      GitHub::Markup::Implementation.new(/foo/, ["DefinitelyNotALinguistLanguage"])
    end
    assert_match(/no match for language/, err.message)
  end

  # --- markups.rb wikicloth idempotent ESCAPED_TAGS<<'tt' both branches ---

  def test_mediawiki_render_is_idempotent_for_escaped_tags
    body = "==Hello==\nworld"
    # First render adds 'tt'; second render hits the `else` branch of `unless include?('tt')`.
    GitHub::Markup.render("README.mediawiki", body)
    count_after_first = WikiCloth::WikiBuffer::HTMLElement::ESCAPED_TAGS.count('tt')
    GitHub::Markup.render("README.mediawiki", body)
    count_after_second = WikiCloth::WikiBuffer::HTMLElement::ESCAPED_TAGS.count('tt')
    assert_equal 1, count_after_first, "first render should leave exactly one 'tt' entry"
    assert_equal 1, count_after_second, "second render must not append a duplicate 'tt'"
  end

  # --- command_implementation.rb block arity branches --------------------

  def test_command_block_with_arity_two_receives_rendered_and_content
    captured = nil
    impl = GitHub::Markup::CommandImplementation.new(
      /covarity2/, ['Text'], 'test/fixtures/cat.sh', 'covarity2'
    ) do |rendered, content|
      captured = [rendered, content]
      "two:#{rendered.strip}:#{content}"
    end
    out = impl.render('README.covarity2', 'payload')
    assert_equal ['payload', 'payload'], captured.map(&:strip)
    assert_equal 'two:payload:payload', out
  end

  def test_command_block_with_arity_one_receives_only_rendered
    captured = nil
    impl = GitHub::Markup::CommandImplementation.new(
      /covarity1/, ['Text'], 'test/fixtures/cat.sh', 'covarity1'
    ) do |rendered|
      captured = rendered
      "one:#{rendered.strip}"
    end
    out = impl.render('README.covarity1', 'payload')
    assert_equal 'payload', captured.strip
    assert_equal 'one:payload', out
  end

  def test_command_with_no_block_returns_rendered_output
    impl = GitHub::Markup::CommandImplementation.new(
      /covnoblock/, ['Text'], 'test/fixtures/cat.sh', 'covnoblock'
    )
    assert_equal 'hello', impl.render('README.covnoblock', 'hello').strip
  end

  def test_command_render_falls_back_to_content_when_command_returns_empty
    impl = GitHub::Markup::CommandImplementation.new(
      /covempty/, ['Text'], 'test/fixtures/empty.sh', 'covempty'
    )
    assert_equal 'fallback-body', impl.render('README.covempty', 'fallback-body')
  end

  def test_command_raises_when_subprocess_exits_non_zero
    impl = GitHub::Markup::CommandImplementation.new(
      /covfail/, ['Text'], 'test/fixtures/fail.sh', 'covfail'
    )
    assert_raises(GitHub::Markup::CommandError) { impl.render('README.covfail', 'payload') }
  end

  # --- commonmarker proc legacy option/extension mapping -----------------

  def test_commonmarker_default_option_is_a_noop
    capture = capture_commonmarker_call(commonmarker_opts: [:DEFAULT])
    refute capture[:render].key?(:sourcepos)
    refute capture[:parse].key?(:smart)
    refute capture[:extension].key?(:footnotes)
  end

  def test_commonmarker_sourcepos_option_sets_render_sourcepos
    capture = capture_commonmarker_call(commonmarker_opts: [:SOURCEPOS])
    assert_equal true, capture[:render][:sourcepos]
  end

  def test_commonmarker_hardbreaks_option_enables_render_hardbreaks
    capture = capture_commonmarker_call(commonmarker_opts: [:HARDBREAKS])
    assert_equal true, capture[:render][:hardbreaks]
  end

  def test_commonmarker_nobreaks_option_disables_render_hardbreaks
    # Combine with :HARDBREAKS so the assertion observes a transition true -> false
    capture = capture_commonmarker_call(commonmarker_opts: [:HARDBREAKS, :NOBREAKS])
    assert_equal false, capture[:render][:hardbreaks]
  end

  def test_commonmarker_smart_option_sets_parse_smart
    capture = capture_commonmarker_call(commonmarker_opts: [:SMART])
    assert_equal true, capture[:parse][:smart]
  end

  def test_commonmarker_github_pre_lang_option_sets_render_github_pre_lang
    capture = capture_commonmarker_call(commonmarker_opts: [:GITHUB_PRE_LANG])
    assert_equal true, capture[:render][:github_pre_lang]
  end

  def test_commonmarker_unsafe_option_enables_render_unsafe
    capture = capture_commonmarker_call(commonmarker_opts: [:UNSAFE])
    assert_equal true, capture[:render][:unsafe]
  end

  def test_commonmarker_footnotes_option_enables_extension_footnotes
    capture = capture_commonmarker_call(commonmarker_opts: [:FOOTNOTES])
    assert_equal true, capture[:extension][:footnotes]
  end

  def test_commonmarker_full_info_string_option_sets_render_full_info_string
    capture = capture_commonmarker_call(commonmarker_opts: [:FULL_INFO_STRING])
    assert_equal true, capture[:render][:full_info_string]
  end

  def test_commonmarker_accepts_legacy_no_op_options_without_raising
    [
      :VALIDATE_UTF8,
      :LIBERAL_HTML_TAG,
      :TABLE_PREFER_STYLE_ATTRIBUTES,
      :STRIKETHROUGH_DOUBLE_TILDE,
    ].each do |opt|
      capture = capture_commonmarker_call(commonmarker_opts: [opt])
      refute capture[:render].key?(:sourcepos), "#{opt} should not alter render options"
      refute capture[:parse].key?(:smart), "#{opt} should not alter parse options"
    end
  end

  def test_commonmarker_unknown_option_raises_argument_error
    err = assert_raises(ArgumentError) do
      capture_commonmarker_call(commonmarker_opts: [:TOTALLY_FAKE_OPT])
    end
    assert_match(/unknown commonmarker option:.*TOTALLY_FAKE_OPT/, err.message)
  end

  def test_commonmarker_header_ids_extension_sets_empty_string_prefix
    capture = capture_commonmarker_call(commonmarker_exts: [:header_ids])
    assert_equal "", capture[:extension][:header_ids]
  end

  def test_commonmarker_unknown_extension_raises_argument_error
    err = assert_raises(ArgumentError) do
      capture_commonmarker_call(commonmarker_exts: [:not_a_real_ext])
    end
    assert_match(/unknown commonmarker extension:.*not_a_real_ext/, err.message)
  end

  private

  # Invokes the commonmarker MARKDOWN_GEMS proc against a stubbed Commonmarker
  # constant and returns the parse/render/extension options the proc passed to
  # Commonmarker.to_html.
  def capture_commonmarker_call(options)
    captured = {}
    fake = Module.new
    fake.define_singleton_method(:to_html) do |content, **kwargs|
      captured[:content] = content
      opts = kwargs.fetch(:options, {})
      captured[:parse] = opts[:parse] || {}
      captured[:render] = opts[:render] || {}
      captured[:extension] = opts[:extension] || {}
      "stub-html"
    end
    with_stub_const("Commonmarker", fake) do
      GitHub::Markup::Markdown::MARKDOWN_GEMS
        .fetch("commonmarker")
        .call("payload", options: options)
    end
    captured
  end

  def with_stub_const(path, value)
    parts = path.split("::")
    name = parts.pop
    parent = parts.inject(Object) { |mod, part| mod.const_get(part) }
    had_const = parent.const_defined?(name, false)
    original = parent.const_get(name) if had_const
    parent.send(:remove_const, name) if had_const
    parent.const_set(name, value)
    yield
  ensure
    parent.send(:remove_const, name) if parent.const_defined?(name, false)
    parent.const_set(name, original) if had_const
  end

  def without_linguist
    had_const = Object.const_defined?(:Linguist, false)
    original = Object.const_get(:Linguist) if had_const
    Object.send(:remove_const, :Linguist) if had_const
    yield
  ensure
    Object.const_set(:Linguist, original) if had_const
  end

  def fake_renderer_module(method_name)
    Module.new do
      define_singleton_method(method_name) { |content| "github_markdown:#{content}" }
    end
  end

  def instance_renderer_class(method_name, prefix:)
    Class.new do
      define_method(:initialize) { |content| @__coverage_content = "#{prefix}:#{content}" }
      define_method(method_name) { @__coverage_content }
    end
  end
end
