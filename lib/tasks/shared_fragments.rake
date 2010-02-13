desc 'Render all shared fragments'
task :shared_fragments => :environment do
  puts "Rendering shared fragments into: #{SharedFragmentHelper.shared_fragments_dir}"
  SharedFragmentHelper.render_shared_fragments
end
