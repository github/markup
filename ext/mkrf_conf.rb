require 'rubygems'
require 'rubygems/command.rb'
require 'rubygems/dependency_installer.rb' 
begin
  Gem::Command.build_args = ARGV
  rescue NoMethodError
end 
installer = Gem::DependencyInstaller.new
begin
  unless RUBY_PLATFORM == 'java'
  	$stderr.puts "Now installing posix-spawn. You may want to add 'gem posix-spawn' to the Gemfile of your project."
    installer.install "posix-spawn", "~> 0.3.8"
  end
rescue
  exit(1)
end
