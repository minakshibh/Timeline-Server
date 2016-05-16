module AppNotification
  class Service
    def self.tagging_users_push(notification, users, payload, reportable)
      external_id = {'$in' => users.map { |u| u.external_id }.to_a.flatten}
      Backburner.enqueue Jobs::NotificationJob, notification, external_id, payload
      # create user notification into db
      users.each { |user| Notification.create(:user_id => user.id, :reportable => reportable, :notification => notification, :payload => payload.merge!(:user_id => user.id).to_json) }
    end

    def self.adding_moment_push(notification, users, payload, reportable)
      external_id = {'$in' => users.map { |u| u.external_id }.to_a.flatten}
      Backburner.enqueue Jobs::NotificationJob, notification, external_id, payload
    end
  end
end