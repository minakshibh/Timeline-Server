namespace :delay do
  desc 'Rake task to delete all delayed_jobs table entry'
  task :delete_all_rows => :environment do
    Rails.logger.info "Rake task started at #{DateTime.now}"
    Delayed::Job.destroy_all
    Rails.logger.info "Rake task stop at #{DateTime.now}"
  end
end