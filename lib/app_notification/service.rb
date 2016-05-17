module AppNotification
  class Service
    def self.tagging_users_push(notification, users, payload, reportable_id,reportable_type)
      users = users.map{|user| user.id}.push(reportable_id,reportable_type)
      TaggingAlertWorker.perform_async(notification,payload,users)
    end

    def self.adding_moment_push(notification, users, payload, reportable_id,reportable_type)
      users = users.map{|user| user.id}.push(reportable_id,reportable_type)
      TaggingAlertWorker.perform_async(notification,payload,users)
    end
  end
end