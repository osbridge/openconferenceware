# == Schema Information
# Schema version: 20090510024259
#
# Table name: proposals_users
#
#  proposal_id :integer         
#  user_id     :integer         
#  created_at  :datetime        
#  updated_at  :datetime        
#

class ProposalsUser < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :user

  validates_presence_of :proposal_id
  validates_presence_of :user_id
end
