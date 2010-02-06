namespace :spec do
  namespace :rcov do
    desc 'Run all specs and save the code coverage data'
    Spec::Rake::SpecTask.new(:save) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList['spec/**/*/*_spec.rb']
      t.rcov = true
      t.rcov_opts = lambda do
        IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten + ['--save']
      end
    end

    desc 'Run all specs and display uncovered code since last save of code coverage data'
    Spec::Rake::SpecTask.new(:diff) do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList['spec/**/*/*_spec.rb']
      t.rcov = true
      t.rcov_opts = lambda do
        IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten + ['--text-coverage-diff']
      end
    end

    desc 'Clean up, delete coverage report and coverage status'
    task :clean do
      rm_r 'coverage' rescue nil
      rm_r 'coverage.info' rescue nil
    end
  end
end
