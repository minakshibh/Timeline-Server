namespace :delayed_job do
  desc 'Rake task to delete all delayed_jobs table entry'
  task :delete_all_rows => :environment do
    open("#{Rails.root}/log/cron_log.log", 'a') do |f|
      f.puts "(Delayed job) Start emptying delayed job queue at #{DateTime.now}"
      Delayed::Job.destroy_all
      f.puts "(Delayed Job) Operation successful and ended at #{DateTime.now}"
    end
  end

  desc "Restart the delayed_job process"
  task :restart => :environment do
    system("cd #{Rails.root.to_s}; bin/delayed_job restart")
  end
end

