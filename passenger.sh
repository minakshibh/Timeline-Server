#! /bin/bash

if [ $(cat /var/app/support/pids/passenger.pid) ]
then
   echo "Passenger is running on PID $(cat /var/app/support/pids/passenger.pid) at $(date)"
else
   echo 'Restarting passenger at $(date)'
   sudo service passenger start
fi