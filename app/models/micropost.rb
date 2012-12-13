class Micropost < ActiveRecord::Base
  attr_accessible :content, :recipients, :recipient
  belongs_to :user
  
  has_many :recipients, :dependent => :destroy
  has_many :replied_users, :through => :recipients, :source => "user"

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  DIRECT_MESSAGE_REGEX = /^dm\s([\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z)])*\s/i
  USERNAME_REGEX = /@\w+/i

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 150 }  
  default_scope order: 'microposts.created_at DESC'

  after_save :save_recipients

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    micropost_ids = "SELECT micropost_id FROM recipients WHERE user_id = :user_id"
    where("user_id IN (#{micropost_ids}) OR user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user.id)
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

   def extract_username_from_direct_message
     username = self.content.clone.match( DIRECT_MESSAGE_REGEX )[0].strip
     username.slice!('dm ')
     username
   end

   def message_recipient
     @recipient ||= User.find_by_username(extract_username_from_direct_message)
   end

   def save_recipients
      return unless reply?

      people_replied.each do |user|
        Recipient.create!(:micropost_id => self.id, :user_id => user.id)
      end
   end

    def reply?
      self.content.match( USERNAME_REGEX )
    end

    def people_replied
      users = []
      self.content.clone.gsub!( USERNAME_REGEX ).each do |username|
        user = User.find_by_username(username[1..-1])
        users << user if user
      end
      users.uniq
    end

end

