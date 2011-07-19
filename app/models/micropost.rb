# == Schema Information
#
# Table name: microposts
#
#  id         :integer         not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#


class Micropost < ActiveRecord::Base
  
  # attr_accessible is what is avail from web; think params hash
  attr_accessible  :content 
  
  #make the association to users
  belongs_to :user
  
  validates :content , :presence => true, :length => { :maximum => 140 }
  validates :user_id , :presence => true 
  
  default_scope :order => 'microposts.created_at DESC'
  
  
  
end

