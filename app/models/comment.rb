# == Schema Information
# Schema version: 20090510024259
#
# Table name: comments
#
#  id          :integer         not null, primary key
#  name        :string(255)     
#  email       :string(255)     
#  message     :text            
#  proposal_id :integer         
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Comment < ActiveRecord::Base
  belongs_to :proposal

  validates_presence_of :email, :message, :proposal_id

  # Make sure there's a legitimate proposal attached?!
  validates_presence_of :proposal, :message => "must be present"

  named_scope :listable, :order => "created_at desc", :conditions => "created_at IS NOT NULL"
end
