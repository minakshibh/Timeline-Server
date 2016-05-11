class Video < ActiveRecord::Base
  include ActiveUUID::UUID
  include TaggingNotifications

  # added by insonix
  has_many :notifications,:as=>:reportable,:dependent => :destroy
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

  def update_timeline
   self.timeline.touch
  end
end
