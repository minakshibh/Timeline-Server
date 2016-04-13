module App
  module NotificationService
    def tagging_users_push(notification, users, payload)
      Delayed::Job.enqueue(Jobs::NotificationJob.new(notification, users, payload), {:queue => 'custom_notification_queue', :priority => nil, :run_at => 5.seconds.from_now})
    end

    def tagging_users_push(notification, users, payload)
      Delayed::Job.enqueue(Jobs::NotificationJob.new(notification, users, payload), {:queue => 'custom_notification_queue', :priority => nil, :run_at => 5.seconds.from_now})
    end
  end
end