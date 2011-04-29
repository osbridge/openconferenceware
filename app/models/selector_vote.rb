class SelectorVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :proposal

  validates_presence_of :user
  validates_presence_of :proposal
  validates_presence_of :rating
end
