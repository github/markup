require "simplecov"

SimpleCov.start do
  enable_coverage :branch
  add_filter "/test/"
  add_filter "/spec/"
  add_filter "/features/"
  track_files "lib/**/*.rb"
  command_name "MarkupTests"
  minimum_coverage line: 100, branch: 100
end

module ConstantStubbing
  private

  def with_stub_const(path, value)
    parts = path.split("::")
    name = parts.pop
    parent = parts.inject(Object) { |mod, part| mod.const_get(part) }
    had_const = parent.const_defined?(name, false)
    original = parent.const_get(name) if had_const
    parent.send(:remove_const, name) if had_const
    parent.const_set(name, value)
    yield
  ensure
    parent.send(:remove_const, name) if parent.const_defined?(name, false)
    parent.const_set(name, original) if had_const
  end
end
