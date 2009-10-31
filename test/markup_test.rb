$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'github/markup'
require 'test/unit'
require 'helper'

class MarkupTest < Test::Unit::TestCase
  extend MarkupTestDSL

  def test_graceful_fail
    content = "* One\n* Two"
    text = GitHub::Markup.render('README.imadeitup', content)
    assert_equal content, text
  end

  test 'README.markdown', <<-input, <<-output
* One
* Two
input
<ul>
<li>One</li>
<li>Two</li>
</ul>\n
output

  test 'README.textile', <<-input, <<-output.strip
* One
* Two
input
<ul>
\t<li>One</li>
\t<li>Two</li>
</ul>\n
output

  test 'README.txt', <<-input, <<-output
* One
* Two
input
* One
* Two
output

  test 'README.rst', <<-input, <<-output
1. Blah blah ``code`` blah

2. More ``code``, hooray
input
<ul>
\t<li>One</li>
\t<li>Two</li>
</ul>
output
end
