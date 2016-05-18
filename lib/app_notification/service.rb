module AppNotification
  class Service
    def self.tagging_users_push(notification, users, payload, reportable_id, reportable_type)
      users = users.map { |user| user.id }.push(reportable_id, reportable_type)
      TaggingAlertWorker.perform_async(notification, payload, users)
    end

    def self.adding_moment_push(notification, users, payload, reportable_id, reportable_type)
      users = users.map { |user| user.id }.push(reportable_id, reportable_type)
      TaggingAlertWorker.perform_async(notification, payload, users)
    end

    # def self.find_reportable_and_next_reportable(reportable)
    #
    #   if reportable.class.to_s.eql?('Timeline')
    #     reportable = reportable
    #     next_reportable = nil
    #   else
    #     next_reportable = reportable
    #     reportable = reportable.timeline
    #   end
    #   return reportable, next_reportable
    # end
  end
end