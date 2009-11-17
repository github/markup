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

  def test_fails_gracefully_on_missing_commands
    GitHub::Markup.command(:i_made_it_up, /mde/)
    text = 'hi there'
    assert_equal false, GitHub::Markup.can_render?('README.mde')
    actual = GitHub::Markup.render('README.mde', text)
    assert_equal text, actual
  end

  def test_fails_gracefully_on_missing_env_commands
    GitHub::Markup.command('/usr/bin/env totally_fake', /tf/)
    text = 'hey mang'
    assert_equal false, GitHub::Markup.can_render?('README.tf')
    actual = GitHub::Markup.render('README.tf', text)
    assert_equal text, actual
  end
end
