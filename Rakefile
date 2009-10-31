task :default => :test

desc "Run tests"
task :test do
  Dir['test/**/*_test.rb'].each { |file| require file }
end

desc "Kick it"
task :kick do
  exec "kicker -e rake test lib"
end
