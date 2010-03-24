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
      expected = File.read(expected_file)
      actual = GitHub::Markup.render(readme, File.read(readme))

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
    assert_equal false, GitHub::Markup.can_render?('README.cmd')
  end

  def test_fails_gracefully_on_missing_commands
    GitHub::Markup.command(:i_made_it_up, /mde/)
    text = 'hi there'
    assert GitHub::Markup.can_render?('README.mde')
    actual = GitHub::Markup.render('README.mde', text)
    assert_equal text, actual
  end

  def test_fails_gracefully_on_missing_env_commands
    GitHub::Markup.command('/usr/bin/env totally_fake', /tf/)
    text = 'hey mang'
    assert GitHub::Markup.can_render?('README.tf')
    actual = GitHub::Markup.render('README.tf', text)
    assert_equal text, actual
  end
end
