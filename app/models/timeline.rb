class Timeline < ActiveRecord::Base
  include ActiveUUID::UUID
  include TaggingNotifications

  has_many :videos, dependent: :destroy
  has_many :timeline_notifications,:as=>:reportable,:dependent => :destroy,:class_name=>'Notification'
  belongs_to :user
  # added by insonix
  acts_as_commentable
  has_many :group_timelines, dependent: :destroy
  attr_accessor :participants
  before_validation :normalize_name
  validates_presence_of :user_id, :name
  # validate group timeline participants
  validates_presence_of :participants,:if=> :is_group_timeline?
  validate :timeline_limit_reached, :dublicate_name, on: :create

  acts_as_likeable
  acts_as_followable

  def self.public_or_own(current_user)
    if current_user
      joins(:user)
          .where("users.timelines_public = true OR timelines.user_id = ? OR timelines.user_id IN (?)",
                 current_user.id, Follow.users(current_user))
          .where("timelines.id NOT IN (?) AND timelines.user_id NOT IN (?)",
                 Block.select(:blockable_id).where(:blockable_type => 'Timeline', :user => current_user),
                 Block.select(:blockable_id).where(:blockable_type => 'User', :user => current_user))
    else
      joins(:user).where("users.timelines_public = true")
    end
  end

  def self.search(search)
    where('timelines.name LIKE ?', "%#{search}%")
  end

  def self.followed_by(current_user)
    where("timelines.id IN (?)) OR (timelines.user_id IN (?)", Follow.timelines(current_user), Follow.users(current_user))
  end

  def self.blocked(current_user)
    where("timelines.id IN (?)", Block.select(:blockable_id).where(:blockable_type => 'Timeline', :user => current_user))
  end

  protected

  def normalize_name
    self.name = self.name.gsub(/^[#]*/, '')
  end

  def is_group_timeline?
    self.group_timeline
  end

  def timeline_limit_reached
    if self.user.allowed_timelines_count <= Timeline.where(:user_id => self.user.id).count
      errors.add(:timeline, "limit reached")
    end
  end

  def dublicate_name
    if Timeline.where(:user_id => self.user.id, :name => self.name).count > 0
      errors.add(:name, "already exists in your timelines")
    end
  end
end
