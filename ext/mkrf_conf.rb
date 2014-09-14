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
    installer.install "posix-spawn", "~> 0.3.8"
  end
rescue
  exit(1)
end
