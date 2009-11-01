$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require 'github/markup'

def test_markup
  passed = true
  Dir['test/markups/README.*'].each do |readme|
    next if readme =~ /html$/
    markup = readme.split('.').last

    expected = File.read("#{readme}.html")
    actual = GitHub::Markup.render(readme, File.read(readme))

    if expected == actual
      puts "- #{markup}: OK"
    else
      passed = false
      puts "- #{markup}: FAIL"
      puts "#{markup} expected:", expected
      puts "#{markup} actual:", actual
    end
  end
  passed
end

at_exit do
  exit test_markup ? 0 : 1
end
