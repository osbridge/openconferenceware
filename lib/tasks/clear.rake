desc "Clear everything"
task :clear => ["tmp:clear", "clear:cache"]

desc "Clear cache"
task "clear:cache" => :environment do
  CacheWatcher.expire
  Dir["#{Rails.root}/public/javascripts/cache/*"].each { |filename| rm filename }
end
