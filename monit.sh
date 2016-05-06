#! /bin/bash

if [ $(cat /var/run/monit.pid) ]
then
   echo "Monit is running on PID $(cat /var/run/monit.pid) at $(date)"
else
   echo 'Restarting monit at $(date)'
   sudo service monit restart
fi