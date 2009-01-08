desc "Generate a code coverage report for the tests"
task :rcov do
  sh "rcov test/*/*_test.rb --output=coverage --rails"
  puts "  Generated code coverage report: file://#{Dir.pwd}/coverage/index.html"
end
