class Comment < ActiveRecord::Base
  include ActiveUUID::UUID
  include ActsAsCommentable::Comment
  include TaggingNotifications
  # Added by insonix
  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :user

  acts_as_mentioner
  default_scope -> { order('created_at ASC') }
  validates_presence_of :comment

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable
  # NOTE: Comments belong to a user

end
