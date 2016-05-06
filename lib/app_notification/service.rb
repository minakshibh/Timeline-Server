module AppNotification
  class Service
    def self.tagging_users_push(notification, users, payload)
      Rails.logger.info '===================I am here service=================================='
      Delayed::Job.enqueue Jobs::NotificationJob.new(notification, users, payload)
    end

    def self.adding_moment_push(notification, users, payload)
      Delayed::Job.enqueue Jobs::NotificationJob.new(notification, users, payload)
    end
  end
end