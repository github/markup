$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'github/markup'
require 'test/unit'
require 'nokogiri'
require 'nokogiri/diff'

def normalize_html(text)
  text.strip!
  text.gsub!(/\s\s+/,' ')
  text.gsub!(/\p{Pi}|\p{Pf}|&amp;quot;/u,'"')
  text.gsub!("\u2026",'...')
  text
end

def assert_html_equal(expected, actual, msg = nil)
  assert_block(msg) do
    expected_doc = Nokogiri::HTML(expected) {|config| config.noblanks}
    actual_doc   = Nokogiri::HTML(actual) {|config| config.noblanks}

    expected_doc.search('//text()').each {|node| node.content = normalize_html node.content}
    actual_doc.search('//text()').each {|node| node.content = normalize_html node.content}

    expected_doc.diff(actual_doc) do |change, node|
      if change != ' ' && !node.blank? then
        if change == "+"
          break unless node.to_html =~ /id="*"/
        end
      end
    end
  end
end

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

      assert_html_equal expected, actual, <<message
#{File.basename expected_file}'s contents are not html equal to output:
#{diff}
message
    end
  end

  def test_knows_what_it_can_and_cannot_render
    assert_equal false, GitHub::Markup.can_render?('README.html')
    assert_equal true, GitHub::Markup.can_render?('README.markdown')
    assert_equal false, GitHub::Markup.can_render?('README.cmd')
    assert_equal true, GitHub::Markup.can_render?('README.litcoffee')
  end

  def test_raises_error_if_command_exits_non_zero
    GitHub::Markup.command('echo "failure message">&2 && false', /fail/)
    assert GitHub::Markup.can_render?('README.fail')
    begin
      GitHub::Markup.render('README.fail', "stop swallowing errors")
    rescue GitHub::Markup::CommandError => e
      assert_equal "failure message", e.message
    else
      fail "an exception was expected but was not raised"
    end
  end
end
