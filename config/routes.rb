Rails.application.routes.draw do

  scope '/api' do
    scope '/user' do
      #--------------------- created by insonix --------------------------#
      get 'timeline_notifications' => 'user#timeline_notifications'
      get 'my_followers' => 'user#my_followers'
      #-------------------------------------------------------------------#
      get '/' => 'user#index', defaults: {format: :json}
      get 'get_token' => 'user#get_token', defaults: {format: :json}
      get 'me' => 'user#me', defaults: {format: :json}
      post 'update' => 'user#update'
      post 'increment_timelines' => 'user#increment_timelines'
      post '/delete' => 'user#destroy'
      get '/follow_queue' => 'user#follow_queue', defaults: {format: :json}
      get '/following' => 'user#following', defaults: {format: :json}
      get '/followers' => 'user#followers', defaults: {format: :json}
      get '/blocked' => 'user#blocked', defaults: {format: :json}
      get '/notifications' => 'user#notifications'
      post '/settings' => 'user#set_settings'
      get '/:id/followers' => 'user#user_followers', defaults: {format: :json}
      get '/:id/likers' => 'user#likers', defaults: {format: :json}
      post '/:id/follow' => 'user#follow'
      post '/:id/unfollow' => 'user#unfollow'
      post '/:id/like' => 'user#like'
      post '/:id/unlike' => 'user#unlike'
      post '/:id/block' => 'user#block'
      post '/:id/unblock' => 'user#unblock'
      post '/:id/accept' => 'user#accept'
      post '/:id/decline' => 'user#decline'
      get '/:id' => 'user#show', defaults: {format: :json}
    end
    scope '/timeline' do
      #--------------------- added by insonix --------------------------#
      get '/:id/comments' => 'timeline#fetch_comments'
      post '/:id/comment' => 'timeline#post_comment'
      post 'create_group_timeline' => 'timeline#create_group_timeline', defaults: {format: :json}
      #-------------------------------------------------------------------#
      get '/:id/videos' => 'timeline#show_videos', defaults: {format: :json}
      get '/:id/followers' => 'timeline#followers', defaults: {format: :json}
      get '/:id/likers' => 'timeline#likers', defaults: {format: :json}
      post '/:id/like' => 'timeline#like'
      post '/:id/unlike' => 'timeline#unlike'
      post '/:id/follow' => 'timeline#follow'
      post '/:id/unfollow' => 'timeline#unfollow'
      post '/:id/block' => 'timeline#block'
      post '/:id/unblock' => 'timeline#unblock'
      post 'create' => 'timeline#create', defaults: {format: :json}
      get '/blocked' => 'timeline#blocked', defaults: {format: :json}
      get '/me' => 'timeline#me', defaults: {format: :json}
      get '/' => 'timeline#index', defaults: {format: :json}
      get '/user/:user_id' => 'timeline#user', defaults: {format: :json}
      get '/following' => 'timeline#following', defaults: {format: :json}
      get '/trending' => 'timeline#trending', defaults: {format: :json}
      get '/followers' => 'timeline#all_followers', defaults: {format: :json}
      get '/:id' => 'timeline#show', defaults: {format: :json}
      delete '/:id' => 'timeline#destroy'

    end

    scope :group_timeline do
      #--------------------- added by insonix --------------------------#
      #-------------------------------------------------------------------#
      delete '/:id/remove_group_participant/:participant_id' => 'group_timeline#remove_participant'
      patch '/:id/add_remove_participant_by_admin' => 'group_timeline#add_remove_participant'
      delete '/:id/destroy_group_timeline_by_admin' => 'group_timeline#destroy_group_timeline'
      #-------------------------------------------------------------------#
    end

    scope :comment do
      #--------------------- added by insonix ----------------------------#
      patch '/:id/edit' => 'comment#edit'
      delete '/:id/delete' => 'comment#delete'
      #-------------------------------------------------------------------#
    end

    scope '/video' do
      #--------------------- added by insonix --------------------------#
      get '/:id/comments' => 'video#fetch_comments'
      post '/:id/comment' => 'video#post_comment'
      #-------------------------------------------------------------------#
      put 'create' => 'video#create'
      post 'create' => 'video#create'
      get '/:id' => 'video#show'
    end
    scope '/search' do
      get '/:q' => 'search#index'
      get '/' => 'search#index'
    end
  end

  get '/user/:user_name/timeline/:timeline_name' => 'timeline#webview'
  get '/user/:user_name' => 'user#webview'

  get '/support' => redirect("http://go.mytimelineapp.com/support/")
  get '/privacypolicy' => redirect("http://go.mytimelineapp.com/privacy/")

  health_check_routes

  get '/' => redirect("http://go.mytimelineapp.com/")

  root 'home#index'

  match "*path", to: "application#page_not_found", via: :all

end
