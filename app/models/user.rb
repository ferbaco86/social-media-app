class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 20 }

  has_many :posts
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :friendships
  has_many :inverse_friendships, class_name: 'Friendship', foreign_key: 'friend_id'

  # Array of users who are already friends
  def friends
    friends_array = friendships.map { |friendship| friendship.friend if friendship.confirmed }
    friends_array += friendships.map { |friendship| friendship.user if friendship.confirmed }
    friends_array.compact
  end

  # Users who have yet to confirme friend requests
  def pending_friends
    friendships.map { |friendship| friendship.friend if friendship.confirmed }.compact
  end

  # Users who have requested to be friends
  def friend_requests
    friendships.map { |friendship| friendship.friend unless friendship.confirmed }.compact
  end

  # Confirm user as friend
  def confirm_friend(user)
    friendship = Friendship.find { |friend| friend.friend == user }
    friendship.confirmed = true
    friendship.save
  end

  # Checks if user is a friend
  def friend?(user)
    friends.include?(user)
  end

  def friends_post(current_user)
    Post.where(user: friends).or(Post.where(user: current_user))
  end
end
