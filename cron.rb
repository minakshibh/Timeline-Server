#!/usr/bin/ruby -w
require 'logger'
$LOG = Logger.new('cron_log.log', 'monthly')
delayed_job_status = system("/home/insonix/RubymineProjects/Timeline/test_1.sh")
# passenger_status = system("/home/insonix/RubymineProjects/Timeline/test_1.sh")

case delayed_job_status
  when 0
  when 1
end