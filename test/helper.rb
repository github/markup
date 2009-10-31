module MarkupTestDSL
  def test(filename, input, output)
    ext = filename.split('.').last
    define_method "test_#{ext}" do
      assert_equal output, GitHub::Markup.render(filename, input)
    end
  end
end
