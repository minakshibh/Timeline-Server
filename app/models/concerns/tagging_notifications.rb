include App::NotificationService
module TaggingNotifications
  extend ActiveSupport::Concern
  # Write you class method here
  module ClassMethods

    def tagging(current_user, tag_users, commentable, comment)
      tagging_user_ids = []
      payload = {}
      tag_users.split(',').each { |tag_user_id| tagging_user_ids.push(tag_user_id) }
      users = User.where(:id => tagging_user_ids)
      users.each { |user| comment.mention!(user) }
      case commentable.class.to_s
        when 'Timeline'
          payload.merge!({:timeline_id => commentable.id, :name => commentable.name, :action => 'tagging'})
          # send tagging push notification by parse
          tagging_users_push("@#{current_user.name} mention you in feedeo ##{commentable.name} comment", users, payload)
        when 'Video'
          payload.merge!(:video_id => commentable.id, :timeline_id => commentable.timeline_id, :action => 'tagging')
          # send tagging push notification by parse
          tagging_users_push("@#{current_user.name} mention you in moment ##{commentable.timeline.name} comment", users, payload)
      end
    end

  end
end