namespace :user do
  desc 'Rake task to update all user images'
  task :update_all_users_images => :environment do
    User.all.each do |user|
      user_image = user.parse_profile_image rescue ''
      user.update_column('image', user_image)
    end
  end
end