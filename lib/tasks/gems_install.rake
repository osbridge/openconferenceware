Rake.application.instance_variable_get(:@tasks).delete('gems:install')

task 'gems:install' do
  puts <<-EOB
ERROR: The "gems:install" task is obsolete. Please run this instead:
  bundle check || bundle install
  EOB
end
