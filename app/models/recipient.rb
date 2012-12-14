class Recipient < ActiveRecord::Base
  attr_accessible :micropost_id, :user_id

  belongs_to :micropost
  belongs_to :user
  default_scope order: 'recipients.created_at DESC'


end
