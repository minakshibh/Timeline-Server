namespace :user do
  desc 'Rake task to update all user images'
  task :update_all_users_images => :environment do
    User.all.each do |user|
      user_image = user.parse_profile_image rescue ''
      user.update_column('image', user_image)
    end
  end
  desc 'Rake task to check user sign_in'
  task :user_sign_in => :environment do
    # check session against Parse
    # session_token = 'r%3ANKsJJLuGepIszHAuo0ivWa6L4'

    session_token = 'OBqCdGBpqeD1M8EIoR4nSV7A7'

    uri = URI.parse("https://api.parse.com/1/users/me")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    response = nil

    http.start do |h|
      request = Net::HTTP::Get.new uri.request_uri
       #request['X-Parse-Application-Id'] = "LiynFqjSP5wmP8QfzLQLgm8tGStY3Jt5FeH34lhS"
      request['X-Parse-Application-Id'] = "Zlos4Gg3l7oIeyfekTgMNrA5ENWoHmyKGuRiM39C"
      #request['X-Parse-REST-API-Key'] = "0NZmxMSRfvytkLw05nXEcTpXSAgzP22KW5RpFmpY"
       request['X-Parse-REST-API-Key'] = "ZzxcBVYpinitFMF5k7JXmfDLXoBPArNtVFo0ZD58"
      request['X-Parse-Session-Token'] = session_token
      puts "========session_token=#{session_token}"
      response = h.request request

      puts "===========response=#{response.inspect}"
    end

    # Check if session is valid
    user = JSON.parse(response.body)

    puts "========use=#{user}"
    end
end