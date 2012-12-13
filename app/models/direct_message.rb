class DirectMessage < ActiveRecord::Base
  attr_accessible :content, :recipient_id, :sender_id

  belongs_to :sender, :class_name => User.name
  belongs_to :recipient, :class_name => User.name

  validates :content, :presence => true
  validates :sender, :presence => true
  validates :recipient, :presence => true
  default_scope order: 'direct_messages.created_at DESC'


end
