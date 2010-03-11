#!/usr/bin/env ruby

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"
require 'github/markup'

if ARGV[0] && File.exists?(file = ARGV[0])
  puts GitHub::Markup.render(file)
else
  puts "usage: #$0 FILE"
end
