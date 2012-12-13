class Micropost < ActiveRecord::Base
  attr_accessible :content
  attr_accessor :recipient
  belongs_to :user

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  DIRECT_MESSAGE_REGEX = /^d\s([\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z)])*\s/i

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 150 }  
  default_scope order: 'microposts.created_at DESC'

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user.id)
  end

  def direct_message_format?
    self.content.clone.match(DIRECT_MESSAGE_REGEX) && message_recipient
  end

  def to_direct_message_hash
    body = self.content.clone
    body.slice!(DIRECT_MESSAGE_REGEX) # remove 'd username '
    { :content => body, :sender_id => self.user_id,
      :recipient_id => message_recipient.id } 	 
  end

  private

   def extract_email_from_direct_message
     email = self.content.clone.match( DIRECT_MESSAGE_REGEX )[0].strip
     email.slice!('d ')
     email
   end

   def message_recipient
     @recipient ||= User.find_by_email(extract_email_from_direct_message)
   end
end

