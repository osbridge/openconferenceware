class ConvertTimesToUtc < ActiveRecord::Migration
  def self.up
    count = 0

    Proposal.find(:all).each do |proposal|
      proposal.update_attributes(
        :created_at => proposal.created_at_before_type_cast,
        :updated_at => proposal.updated_at_before_type_cast
      )

      print "."
      STDOUT.flush
      count += 1
    end

    puts
    puts "Updated times for #{count} proposals"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Cannot migrate down."
  end
end
