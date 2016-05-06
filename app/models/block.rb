class Block < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :user
  belongs_to :blockable, :polymorphic => true
end
