class Comment < ActiveRecord::Base
  include ActiveUUID::UUID
  include ActsAsCommentable::Comment
  # Added by insonix
  belongs_to :commentable, :polymorphic => true,:counter_cache => true
  acts_as_mentioner
  default_scope -> { order('created_at ASC') }
  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable
   validates_presence_of :comment
  # NOTE: Comments belong to a user
  belongs_to :user
end
