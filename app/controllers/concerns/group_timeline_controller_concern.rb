module GroupTimelineControllerConcern
  extend ActiveSupport::Concern
  included do
    # write here your controller callbacks
  end

  # Write you methods here
  #------------------ This method is use to add/delete participants by admin from group timeline ---------------#
  #----------------------------- Added by insonix ---------------------------------------------------------------#

  def participant_add_delete_by_admin
    participants = @timeline.group_timelines.first.participants
    case params[:action_type].to_s
      when '0'
        # action_type => 0 to add a new participant
        params[:participants].to_s.split(',').each { |participant| participants.push(participant) }
        @timeline.group_timelines.first.update_column('participants', participants)
        render :json => {:status_code => 200, :message => 'Participant added successfully'}
      when '1'
        # action_type => 1 to remove an existing participant
        params[:participants].to_s.split(',').each { |participant| participants.delete_if { |value| value.to_s.eql?(participant.to_s) } }
        @timeline.group_timelines.first.update_column('participants', participants)
        render :json => {:status_code => 200, :message => 'Participant removed successfully'}
      else
        render :json => {:status_code => 404, :message => 'action_type not found'}
    end
  end

end