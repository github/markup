# encoding: utf-8

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require_relative 'test_helper'
require 'github-markup'
require 'github/markup'
require 'minitest/autorun'
require 'html_pipeline'
require 'nokogiri'
require 'nokogiri/diff'
require 'base64'
require 'tmpdir'

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
  class MarkupFilter < HTMLPipeline::ConvertFilter
    def call(_text, context: {})
      filename = context[:filename] || @context[:filename]
      GitHub::Markup.render(filename, File.read(filename)).strip.force_encoding("utf-8")
    end
  end

  Pipeline = HTMLPipeline.new(
    convert_filter: MarkupFilter.new,
    sanitization_config: HTMLPipeline::SanitizationFilter::DEFAULT_CONFIG
  )

  Dir['test/markups/README.*'].each do |readme|
    next if readme =~ /html$/
    markup = readme.split('/').last.gsub(/^README\./, '')

    define_method "test_#{markup}" do
      skip "Skipping MediaWiki test because wikicloth is currently not compatible with JRuby." if markup == "mediawiki" && RUBY_PLATFORM == "java"
      source = File.read(readme)
      expected_file = "#{readme}.html"
      expected = File.read(expected_file).rstrip
      actual = Pipeline.call("", context: { filename: readme })[:output].to_s

      if source != expected
        assert(source != actual, "#{markup} did not render anything")
      end

      diff = IO.popen("diff -u - #{expected_file}", 'r+') do |f|
        f.write actual
        f.close_write
        f.read
      end

      if ENV['UPDATE']
        File.open(expected_file, 'w') { |f| f.write actual }
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
      assert_equal "failure message", e.message.strip
    else
      fail "an exception was expected but was not raised"
    end
  end

  def test_preserve_markup
    content = "Noël"
    assert_equal content.encoding.name, GitHub::Markup.render('Foo.rst', content).encoding.name
  end

  Diagrams = GitHub::Markup::Diagrams

  PLANTUML_SOURCE = "@startuml\nAlice -> Bob: hi\n@enduml".freeze

  # A stand-in for an asciidoctor-diagram block processor, so the local rendering
  # path can be exercised without a JVM or any other diagram toolchain.
  FakeProcessor = Struct.new(:context, :target) do
    def process(parent, reader, attrs)
      @seen_attrs = attrs
      reader.read
      block = Asciidoctor::Block.new(parent, context, :content_model => :empty)
      block.set_attr("target", target)
      block
    end

    attr_reader :seen_attrs
  end

  # minitest 6 dropped minitest/mock, so stubbing is done by hand. Swaps a
  # singleton method for the duration of the block: a callable value is invoked,
  # anything else is returned as-is.
  def with_stub(target, name, value)
    singleton = target.singleton_class
    own = singleton.instance_methods(false).include?(name) ||
          singleton.private_instance_methods(false).include?(name)
    singleton.send(:alias_method, :__stubbed_original, name) if own
    singleton.send(:define_method, name) do |*args, &blk|
      value.respond_to?(:call) ? value.call(*args, &blk) : value
    end
    yield
  ensure
    singleton.send(:remove_method, name)
    if own
      singleton.send(:alias_method, name, :__stubbed_original)
      singleton.send(:remove_method, :__stubbed_original)
    end
  end

  def render_adoc(content, options: {})
    GitHub::Markup.render("README.adoc", content, options: options)
  end

  def plantuml_block(style: "plantuml", attrs: nil)
    "[#{[style, attrs].compact.join(",")}]\n----\n#{PLANTUML_SOURCE}\n----\n"
  end

  # Renders with the local backend swapped out for a fake, which is also what
  # keeps these tests from depending on a diagram toolchain being installed.
  def render_with_local(processor, content = plantuml_block, options: {})
    with_stub(Diagrams, :local_processor_for, processor) { render_adoc(content, options: options) }
  end

  def img_in(html)
    Nokogiri::HTML(html).at_css("img")
  end

  def pre_in(html)
    Nokogiri::HTML(html).at_css("pre")
  end

  # --- Local rendering via asciidoctor-diagram ------------------------------

  def test_local_rendering_inlines_the_generated_image_as_a_data_uri
    Dir.mktmpdir do |dir|
      path = File.join(dir, "diagram.svg")
      File.binwrite(path, "<svg>hello</svg>")

      html = render_with_local(FakeProcessor.new(:image, path))
      assert_equal "data:image/svg+xml;base64,#{Base64.strict_encode64("<svg>hello</svg>")}",
                   img_in(html)["src"]
    end
  end

  def test_local_rendering_uses_the_mime_type_of_the_requested_format
    Dir.mktmpdir do |dir|
      path = File.join(dir, "diagram.png")
      File.binwrite(path, "PNGDATA")

      html = render_with_local(FakeProcessor.new(:image, path), plantuml_block(attrs: "format=png"))
      assert img_in(html)["src"].start_with?("data:image/png;base64,")
    end
  end

  # asciidoctor-diagram reports a failed render by handing back a listing block
  # rather than by raising, so that is what has to be detected.
  def test_local_rendering_falls_back_when_the_backend_reports_failure
    html = render_with_local(FakeProcessor.new(:listing, "/nonexistent.svg"))
    assert_nil img_in(html)
    assert_equal "plantuml", pre_in(html)["lang"]
  end

  def test_local_rendering_falls_back_when_the_generated_file_is_missing
    html = render_with_local(FakeProcessor.new(:image, "/nonexistent/diagram.svg"))
    assert_nil img_in(html)
    assert_equal "plantuml", pre_in(html)["lang"]
  end

  def test_local_rendering_falls_back_to_the_default_format_for_an_unsupported_one
    Dir.mktmpdir do |dir|
      path = File.join(dir, "diagram.svg")
      File.binwrite(path, "<svg/>")
      processor = FakeProcessor.new(:image, path)
      render_with_local(processor, plantuml_block(attrs: "format=exe"))

      assert_equal "svg", processor.seen_attrs["format"]
    end
  end

  def test_local_rendering_uses_an_explicit_alt_and_role_when_given
    Dir.mktmpdir do |dir|
      path = File.join(dir, "diagram.svg")
      File.binwrite(path, "<svg/>")

      html = render_with_local(FakeProcessor.new(:image, path),
                               plantuml_block(attrs: 'alt="my diagram",role="custom"'))
      assert_equal "my diagram", img_in(html)["alt"]
      assert_includes Nokogiri::HTML(html).at_css("div.imageblock")["class"], "custom"
    end
  end

  # A data URI only survives a sanitizer that allows the data: protocol on
  # img/src, which the stock html-pipeline config does not. Pinned here because
  # it is the difference between a rendered diagram and a broken image for any
  # consumer that sanitizes -- see the README.
  def test_local_rendering_image_requires_data_uris_to_be_allowed_by_the_sanitizer
    Dir.mktmpdir do |dir|
      path = File.join(dir, "diagram.svg")
      File.binwrite(path, "<svg/>")
      rendered = render_with_local(FakeProcessor.new(:image, path))

      default = HTMLPipeline::SanitizationFilter::DEFAULT_CONFIG
      stripped = HTMLPipeline::SanitizationFilter.call(rendered, default).to_s
      assert_nil img_in(stripped)["src"], "expected the default config to drop the data: URI"

      img_protocols = default[:protocols]["img"]
      permissive = default.merge(
        :protocols => default[:protocols].merge(
          "img" => img_protocols.merge("src" => img_protocols["src"] + ["data"])
        )
      )
      survived = HTMLPipeline::SanitizationFilter.call(rendered, permissive).to_s
      assert img_in(survived)["src"].start_with?("data:image/svg+xml;base64,"),
             "expected the data: URI to survive once the protocol is allowed"
    end
  end

  def test_local_rendering_asks_the_backend_for_an_absolute_path
    Dir.mktmpdir do |dir|
      path = File.join(dir, "diagram.svg")
      File.binwrite(path, "<svg/>")
      processor = FakeProcessor.new(:image, path)
      render_with_local(processor)

      # Passed per block, never as a document attribute, so that ordinary
      # image:: macros in the same file are left alone.
      assert_equal "", processor.seen_attrs["data-uri"]
      assert_equal "svg", processor.seen_attrs["format"]
    end
  end

  def test_ordinary_images_are_not_inlined_by_the_local_rendering_path
    Dir.mktmpdir do |dir|
      path = File.join(dir, "diagram.svg")
      File.binwrite(path, "<svg/>")

      html = render_with_local(FakeProcessor.new(:image, path),
                              "#{plantuml_block}\nimage::ordinary.png[]\n")
      assert_equal ["ordinary.png"],
                   Nokogiri::HTML(html).css("img").map { |i| i["src"] }.reject { |s| s.start_with?("data:") }
    end
  end

  def test_local_processor_is_built_for_a_known_diagram_type
    Diagrams.instance_variable_set(:@local_processors, nil)
    processor = Diagrams.local_processor_for("plantuml")
    assert_instance_of Asciidoctor::Diagram::PlantUmlBlockProcessor, processor

    # Memoised, so a second lookup does not pay for the require again.
    assert_same processor, Diagrams.local_processor_for("plantuml")
  ensure
    Diagrams.instance_variable_set(:@local_processors, nil)
  end

  def test_local_processor_is_nil_when_asciidoctor_diagram_is_absent
    Diagrams.instance_variable_set(:@local_processors, nil)
    with_stub(Diagrams, :require, ->(*) { raise LoadError }) do
      assert_nil Diagrams.local_processor_for("plantuml")
    end
  ensure
    Diagrams.instance_variable_set(:@local_processors, nil)
  end

  def test_local_rendering_is_skipped_entirely_when_the_gem_is_absent
    with_stub(Diagrams, :local_rendering_installed?, false) do
      html = render_adoc(plantuml_block)
      assert_nil img_in(html)
      assert_equal "plantuml", pre_in(html)["lang"]
    end
  end

  def test_local_rendering_installed_is_detected_from_the_gem_index
    Diagrams.remove_instance_variable(:@local_rendering_installed) if
      Diagrams.instance_variable_defined?(:@local_rendering_installed)
    assert_equal true, Diagrams.local_rendering_installed?
    assert_equal true, Diagrams.local_rendering_installed?, "should be memoised"

    Diagrams.remove_instance_variable(:@local_rendering_installed)
    with_stub(Gem::Specification, :find_by_name, ->(*) { raise Gem::LoadError }) do
      assert_equal false, Diagrams.local_rendering_installed?
    end
  ensure
    Diagrams.remove_instance_variable(:@local_rendering_installed) if
      Diagrams.instance_variable_defined?(:@local_rendering_installed)
  end

  # --- Fallback and isolation ----------------------------------------------

  # With no backend at all, the diagram language is still carried on the <pre> so
  # a client-side renderer can pick it up.
  def test_diagram_falls_back_to_a_tagged_source_block
    html = render_with_local(nil)
    assert_nil img_in(html)
    assert_equal "plantuml", pre_in(html)["lang"]
    assert_equal PLANTUML_SOURCE, pre_in(html).text.strip
  end

  def test_diagram_leaves_ordinary_source_blocks_alone
    html = render_adoc("[source,mermaid]\n----\ngraph TD; A-->B;\n----\n")
    assert_nil img_in(html)
    assert_equal "mermaid", pre_in(html)["lang"]
  end

  def test_diagrams_do_not_register_extensions_globally
    render_with_local(nil)
    assert_empty Asciidoctor::Extensions.groups,
                 "diagram blocks must not leak into Asciidoctor's global registry"
  end

  def test_every_diagram_type_maps_to_a_real_asciidoctor_diagram_processor
    Diagrams::LOCAL_EXTENSIONS.each do |type, (path, class_name)|
      require path
      assert Asciidoctor::Diagram.const_defined?(class_name),
             "#{type} maps to missing Asciidoctor::Diagram::#{class_name}"
    end
  end

  def test_commonmarker_options
    assert_equal "<p>hello <!-- raw HTML omitted --> world</p>\n", GitHub::Markup.render("test.md", "hello <bad> world")
    assert_equal "<p>hello <bad> world</p>\n", GitHub::Markup.render("test.md", "hello <bad> world", options: {commonmarker_opts: [:UNSAFE]})

    assert_equal "<p>hello <!-- raw HTML omitted --> world</p>\n", GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, "hello <bad> world")
    assert_equal "<p>hello <bad> world</p>\n", GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, "hello <bad> world", options: {commonmarker_opts: [:UNSAFE]})

    assert_equal "&lt;style>.red{color: red;}&lt;/style>\n", GitHub::Markup.render("test.md", "<style>.red{color: red;}</style>", options: {commonmarker_opts: [:UNSAFE]})
    assert_equal "<style>.red{color: red;}</style>\n", GitHub::Markup.render("test.md", "<style>.red{color: red;}</style>", options: {commonmarker_opts: [:UNSAFE], commonmarker_exts: [:autolink, :table, :strikethrough]})

    assert_equal "&lt;style>.red{color: red;}&lt;/style>\n", GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, "<style>.red{color: red;}</style>", options: {commonmarker_opts: [:UNSAFE]})
    assert_equal "<style>.red{color: red;}</style>\n", GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, "<style>.red{color: red;}</style>", options: {commonmarker_opts: [:UNSAFE], commonmarker_exts: [:autolink, :table, :strikethrough]})
  end
end
