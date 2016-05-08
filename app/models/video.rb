class Video < ActiveRecord::Base
  include ActiveUUID::UUID
  include TaggingNotifications

  # added by insonix
  acts_as_commentable
  belongs_to :timeline

  default_scope { order('created_at ASC') }

  has_attached_file :video,
                    :styles => {
                        :thumb => {:geometry => "360x360#", :format => 'jpg', :time => 0.1},
                        :lowres => {:geometry => "360x360#", :format => 'mp4'}
                    }, only_process: [:thumb], :processors => [:transcoder],
                    :path => ":class/:id/:style/:basename.:extension"

  validates_attachment_content_type :video, :content_type => ["video/mp4", "video/mov", "video/mpeg", "video/mpeg4", "video/quicktime", "image/jpg", "image/jpeg"]

  before_post_process do
    file = self.video.queued_for_write[:original].path
    self.duration = Paperclip.run("ffprobe", '-i %s -show_entries format=duration -v quiet -of csv="p=0"' % file).to_f
  end

  process_in_background :video, only_process: [:lowres]

  validates_presence_of :timeline_id

  after_save :update_timeline

  def serializable_hash (params={})
    super.merge(
        video_url: self.video.url,
        video_thumb: self.video.url(:thumb),
        video_lowres: self.video.url(:lowres)
    )
  end

  # def self.tagging(current_user, tag_users, video, comment)
  #   tagging_user_ids = []
  #   payload = {}
  #   tag_users.split(',').each { |tag_user_id| tagging_user_ids.push(tag_user_id) }
  #   users = User.where(:id => tagging_user_ids)
  #   users.each { |user| comment.mention!(user) }
  #   payload.merge!(:video_id => video.id,:timeline_id=>video.timeline_id,:action=>'tagging')
  #   # send tagging push notification by parse
  #   tagging_users_push("@#{current_user.name} mention you in moment ##{video.timeline.name} comment", users, payload)
  # end

  # def self.group_alert(current_user,video)
  #   payload = {}
  #   users = User.where(:id => video.timeline.group_timelines.first.participants.push(video.timeline.user.id))
  #   payload.merge!({:video_id => video.id, :timeline_id => video.timeline_id,:action=>'group_alert' })
  #   # send moment push notification by parse
  #   adding_moment_push("@#{current_user.name} added a moment in feedeo ##{video.timeline.name}", users, payload)
  # end


  def update_timeline
   self.timeline.touch
  end
end
