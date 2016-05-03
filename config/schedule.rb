# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#/var/app/current
#
set :output, "/home/insonix/RubymineProjects/Timeline/log/cron_log.log"

every 1.minute do
  command "/var/app/current/delsy.sh"
  command "/var/app/current/passenger.sh"
end

every 5.minutes do
  rake 'delayed_job:restart'
end

every :reboot do
  command "/var/app/current/delsy.sh"
end

every :day, :at => '5:00pm' do # execute at 12PM (CST) every day
  rake 'delayed_job:delete_all_rows'
end

# Learn more: http://github.com/javan/whenever
