class Relationship < ActiveRecord::Base
  
  # remember, attr_accessible is what is avail to web interface
  # followed_id is the id of the user *I'm* following
  # if we allowed the other way, could change who other people follow
  attr_accessible  :followed_id
  
  # note - book does NOT have the foreign key in there
  belongs_to :follower, :foreign_key => "follower_id", :class_name => "User"
  belongs_to :followed, :foreign_key => "followed_id", :class_name => "User"
  
  validates :follower_id, :presence => true
  validates :followed_id, :presence => true
  
end
