class GroupTimelineController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_timeline
  include GroupTimelineControllerConcern

  def add_remove_participant
    begin
      if admin_authorization?
        participant_add_delete_by_admin
      else
        render :json => {:status_code => 401, :message => 'you are not admin of this timeline'}
      end
    rescue Exception => error
      render :json => {:status_code => 471, :message => error.message}
    end
  end

  def remove_participant
    begin
      participants = @timeline.group_timelines.first.participants
      participants.delete(params[:participant_id])
      @timeline.group_timelines.first.update_column('participants', participants)
      render :json => {:status_code => 200, :message => 'Participant removed successfully'}
    rescue Exception => error
      render :json => {:status_code => 471, :message => error.message}
    end

  end

  def destroy_group_timeline
    begin
      if admin_authorization?
        @timeline.destroy
        render :json => {:status_code => 200, :message => 'Group Timeline deleted successfully'} and return
      else
        render :json => {:status_code => 401, :message => 'you are not admin of this timeline'} and return
      end
    rescue Exception => error
      render :json => {:status_code => 404, :message => error.message}
    end
  end

  private

  def set_timeline
    @timeline = Timeline.find_by_id(params[:id])
    render :json => {:status_code => 404, :message => 'Group Timeline not found'} and return if @timeline.nil?
  end

  def admin_authorization?
    @timeline.group_timelines.first.user_id.to_s.eql?(@current_user.id.to_s) ? true : false
  end

end


