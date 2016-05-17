module AppNotification
  class Service
    def self.tagging_users_push(notification, users, payload, reportable_id,reportable_type)
      users = users.map{|user| user.id}
      users = users.push(reportable_id,reportable_type)
      TaggingAlertWorker.perform_async(notification,payload,users)
      # Backburner.enqueue Jobs::NotificationJob, notification, external_id, payload
    end

    def self.adding_moment_push(notification, users, payload, reportable_id,reportable_type)
      users = users.map{|user| user.id}
      TaggingAlertWorker.perform_async(notification,payload,users,reportable_id,reportable_type)
    end
  end
end