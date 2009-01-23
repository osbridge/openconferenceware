class SeparateUsersFirstAndLastName < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    
    User.find(:all).each do |user|
      unless user.read_attribute(:fullname).nil?
        user.first_name = user.read_attribute(:fullname).split(" ")[0..-2].join(' ')
        user.last_name = user.read_attribute(:fullname).split(" ").last
        user.save
      end
    end
    
    remove_column :users, :fullname
  end

  def self.down
    add_column :users, :fullname, :string
    
    User.find(:all).each do |user|
      user.write_attribute(:fullname, [user.first_name, user.last_name].compact.join(" ")) if ! user.first_name.blank? || ! user.last_name.blank?
      user.save
    end
    
    remove_column :users, :last_name
    remove_column :users, :first_name
  end
end
