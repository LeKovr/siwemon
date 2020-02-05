#!/bin/bash
#
# 
# jean@tender.pro
#
#  run:
#  nohup bash times.sh &

dest=/opt/dcape/var/log/webhook/monitor/timing.log
[ -f $dest ] || echo "Stamp,http,https" > $dest

sleep=2
flag=times.allow

touch $flag
while [ -f $flag ] ; do
  f=$(date +"%F %H:%M:%S")
  t=$(curl -w ',%{time_total}' -s -o /dev/null -o /dev/null 'htt{p,ps}://www.tender.pro/date_time.shtml?check=on')
  echo "$f$t" >> $dest
  sleep $sleep
done
