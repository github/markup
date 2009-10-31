$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'github/markup'
require 'test/unit'

class MarkupTest < Test::Unit::TestCase
  def test_markdown
    markdown = GitHub::Markup.render('README.markdown', "* One\n* Two")
    assert_equal <<markdown, markdown
<ul>
<li>One</li>
<li>Two</li>
</ul>

markdown
  end

  def test_textile
    textile = GitHub::Markup.render('README.textile', "* One\n* Two")
    assert_equal <<textile.strip, textile
<ul>
\t<li>One</li>
\t<li>Two</li>
</ul>
textile
  end

  def test_graceful_fail
    content = "* One\n* Two"
    text = GitHub::Markup.render('README.imadeitup', content)
    assert_equal content, text
  end
end
