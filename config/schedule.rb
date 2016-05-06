# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#/var/app/current
#
set :output, "/home/insonix/RubymineProjects/Timeline/log/cron_log.log"

every 30.minutes do
  rake 'delayed_job:restart'
end

every :reboot do
  rake 'delayed_job:restart'
end


