desc "Publish applications: tags a release, pushes the source, and deploys"
task :publish do
  verbose(true) do
    Rake::Task["tag"].invoke
    sh "hg push"
    sh "cap deploy:migrations"
  end
end
