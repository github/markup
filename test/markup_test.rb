$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'github/markup'
require 'test/unit'

class MarkupTest < Test::Unit::TestCase
  Dir['test/markups/README.*'].each do |readme|
    next if readme =~ /html$/
    markup = readme.split('.').last

    define_method "test_#{markup}" do
      expected = File.read("#{readme}.html")
      actual = GitHub::Markup.render(readme, File.read(readme))

      assert expected == actual, <<-message
#{markup} expected:
#{expected}
#{markup} actual:
#{actual}
message
    end
  end

  def test_knows_what_it_can_and_cannot_render
    assert_equal false, GitHub::Markup.can_render?('README.html')
    assert_equal true, GitHub::Markup.can_render?('README.markdown')
    assert_equal false, GitHub::Markup.can_render?('README.cmd')
  end
end
