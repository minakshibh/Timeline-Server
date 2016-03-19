#! /bin/bash

case "$(pidof delayed_job | wc -w)" in

0)  RAILS_ENV=production /var/app/current/bin/delayed_job start &
    0
    ;;
1)  1
    ;;
*)
    kill $(pidof delayed_job | awk '{print $1}')
    2
    ;;
esac

