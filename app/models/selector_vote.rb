# == Schema Information
# Schema version: 20120427185014
#
# Table name: selector_votes
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)      not null
#  proposal_id :integer(4)      not null
#  rating      :integer(4)      not null
#  comment     :text            
#

class SelectorVote < ActiveRecord::Base
  attr_accessible :rating, :comment, :user, :proposal

  belongs_to :user
  belongs_to :proposal

  validates_presence_of :user
  validates_presence_of :proposal
  validates_presence_of :rating
end
