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
