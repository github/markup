$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'github/markup'
require 'test/unit'

class ProcessorTest < Test::Unit::TestCase
  def test_can_process_code_snippets
    readme = 'test/markups/README.rdoc'
    html = GitHub::Markup.render(readme, File.read(readme))
    puts html
    assert html == ''
  end
end
