class Activity < ActiveRecord::Base
  include ActiveUUID::UUID

  belongs_to :user
  belongs_to :trackable, :polymorphic => true

  after_save :send_notification

  def send_notification
    if self.trackable.present?
      puts "====self=#{self.id}=====trackable=#{self.trackable}"
      if self.trackable_type == 'Timeline'
        TimelineNotificationsWorker.perform_async(self.id)
      elsif self.trackable_type == 'User'
        UserNotificationsWorker.perform_async(self.id)
      elsif self.trackable_type == 'Video'
        VideoNotificationWorker.perform_async(self.id)
      end
    end
  end

end