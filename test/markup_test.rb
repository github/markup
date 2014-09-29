# encoding: UTF-8

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'github/markup'
require 'test/unit'

class MarkupTest < Test::Unit::TestCase
  Dir['test/markups/README.*'].each do |readme|
    next if readme =~ /html$/
    markup = readme.split('/').last.gsub(/^README\./, '')

    define_method "test_#{markup}" do
      source = File.read(readme)

      expected_file = "#{readme}.html"
      expected = File.read(expected_file).rstrip
      actual = GitHub::Markup.render(readme, File.read(readme)).rstrip.force_encoding("utf-8")

      if source != expected
        assert(source != actual, "#{markup} did not render anything")
      end

      diff = IO.popen("diff -u - #{expected_file}", 'r+') do |f|
        f.write actual
        f.close_write
        f.read
      end

      assert expected == actual, <<message
#{File.basename expected_file}'s contents don't match command output:
#{diff}
message
    end
  end

  def test_knows_what_it_can_and_cannot_render
    assert_equal false, GitHub::Markup.can_render?('README.html')
    assert_equal true, GitHub::Markup.can_render?('README.markdown')
    assert_equal true, GitHub::Markup.can_render?('README.rmd')
    assert_equal true, GitHub::Markup.can_render?('README.Rmd')
    assert_equal false, GitHub::Markup.can_render?('README.cmd')
    assert_equal true, GitHub::Markup.can_render?('README.litcoffee')
  end

  def test_each_render_has_a_name
    assert_equal "markdown", GitHub::Markup.renderer('README.md').name
    assert_equal "redcloth", GitHub::Markup.renderer('README.textile').name
    assert_equal "rdoc", GitHub::Markup.renderer('README.rdoc').name
    assert_equal "org-ruby", GitHub::Markup.renderer('README.org').name
    assert_equal "creole", GitHub::Markup.renderer('README.creole').name
    assert_equal "wikicloth", GitHub::Markup.renderer('README.wiki').name
    assert_equal "asciidoctor", GitHub::Markup.renderer('README.adoc').name
    assert_equal "restructuredtext", GitHub::Markup.renderer('README.rst').name
    assert_equal "pod", GitHub::Markup.renderer('README.pod').name
  end

  def test_raises_error_if_command_exits_non_zero
    GitHub::Markup.command('echo "failure message">&2 && false', /fail/, "fail")
    assert GitHub::Markup.can_render?('README.fail')
    begin
      GitHub::Markup.render('README.fail', "stop swallowing errors")
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
end
