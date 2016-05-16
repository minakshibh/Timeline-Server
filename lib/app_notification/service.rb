module AppNotification
  class Service
    def self.tagging_users_push(notification, users, payload,reportable)
      Delayed::Job.enqueue(Jobs::NotificationJob.new(notification, users, payload,reportable),:queue => 'notifications_alert')
    end

    def self.adding_moment_push(notification, users, payload,reportable)
      Delayed::Job.enqueue(Jobs::NotificationJob.new(notification, users, payload,reportable),:queue => 'notifications_alert')
    end
  end
end