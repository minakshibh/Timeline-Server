class CommentController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_comment

  def edit
    if user_authorization?
      validation_status = @comment.update(:comment => params[:comment])
      if validation_status
        Comment.tagging(@current_user, params[:tag_users], @comment.commentable, @comment) if params[:tag_users].present?
        render :json => {:status_code => 200, :message => 'Comment edited successfully'}
      else
        render :json => {:status_code => 422, :message => "#{@comment.errors.full_messages.to_sentence}"}
      end
    else
      render :json => {:status_code => 401, :message => 'You are not authorized'}
    end
  end

  def delete
    if admin_authorization?(@comment.commentable)
      @comment.destroy
      render :json => {:status_code => 200, :message => 'Comment deleted successfully'}
    else
      if user_authorization?
        @comment.destroy
        render :json => {:status_code => 200, :message => 'Comment deleted successfully'}
      else
        render :json => {:status_code => 401, :message => 'You are not authorized'}
      end
    end
  end

  private
  def set_comment
    @comment = Comment.find_by_id(params[:id])
    render :json => {:status_code => 404, :message => 'Comment not found'} and return if @comment.nil?
  end

  def user_authorization?
    @current_user.id.to_s.eql?(@comment.user_id.to_s) ? true : false
  end

  def admin_authorization?(object)
    case object.class.to_s
      when 'Timeline'
        @current_user.id.to_s.eql?(object.user_id.to_s) ? true : false
      when 'Video'
        @current_user.id.to_s.eql?(object.try(:timeline).try(:user_id).to_s) ? true : false
    end

  end
end
