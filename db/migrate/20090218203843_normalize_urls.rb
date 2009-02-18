class NormalizeUrls < ActiveRecord::Migration
  def self.up
    # URLs will be normalized upon save.
    failed = false
    (User.find(:all)+Proposal.find(:all)).each do |record| 
      begin
        record.save!
      rescue Exception => e
        failed = true
        puts "!! Couldn't update #{record.class} ##{record.id}: #{e}"
      end
    end
    puts "At least one database record couldn't be updated, but the others have been coverted successfully" if failed
  end

  def self.down
  end
end
