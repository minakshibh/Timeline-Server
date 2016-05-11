module AppNotification
  class Service
    def self.tagging_users_push(notification, users, payload,reportable)
      Delayed::Job.enqueue Jobs::NotificationJob.new(notification, users, payload,reportable)
    end

    def self.adding_moment_push(notification, users, payload,reportable)
      Delayed::Job.enqueue Jobs::NotificationJob.new(notification, users, payload,reportable)
    end
  end
end