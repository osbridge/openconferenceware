desc "Clear everything"
task :clear => ["tmp:clear", "theme_remove_cache", "clear:cache"]

desc "Clear cache"
task "clear:cache" => :environment do
  Observist.expire
end
