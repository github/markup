task :default => :test

desc "Run tests"
task :test do
  Dir['test/**/*_test.rb'].each { |file| require file }
end

desc "Kick it"
task :kick do
  exec "kicker -e rake test lib"
end

begin
  require 'jeweler'
  $LOAD_PATH.unshift 'lib'
  require 'github/markup/version'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "github-markup"
    gemspec.summary = "The code we use to render README.your_favorite_markup"
    gemspec.description = "The code we use to render README.your_favorite_markup"
    gemspec.email = "chris@ozmm.org"
    gemspec.homepage = "http://github.com/defunkt/github-markup"
    gemspec.authors = ["Chris Wanstrath"]
    gemspec.version = GitHub::Markup::Version
  end
rescue LoadError
  puts "Jeweler not available."
  puts "Install it with: gem install jeweler"
end

begin
  require 'sdoc_helpers'
rescue LoadError
  puts "sdoc support not enabled. Please gem install sdoc-helpers."
end

desc "Build a gem"
task :gem => [ :gemspec, :build ]

desc "Push a new version to Gemcutter"
task :publish => [ :test, :gemspec, :build ] do
  system "git tag v#{GitHub::Markup::Version}"
  system "git push origin v#{GitHub::Markup::Version}"
  system "git push origin master"
  system "gem push pkg/github-markup-#{GitHub::Markup::Version}.gem"
  system "git clean -fd"
  #exec "rake pages"
end
